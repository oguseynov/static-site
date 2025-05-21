#!/bin/bash

set -e

CLUSTER_NAME=static-site
DOMAIN_NAME="dev.test"

# Start Minikube cluster if it doesn't exist
if ! minikube status -p "${CLUSTER_NAME}" >/dev/null 2>&1; then
  minikube start -p "${CLUSTER_NAME}" --driver=docker
else
  echo "Minikube cluster '${CLUSTER_NAME}' already exists. Skipping creation."
fi

rm -f /tmp/tls.key /tmp/tls.crt
echo "Generating self-signed certificate..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /tmp/tls.key -out /tmp/tls.crt \
  -subj "/CN=${DOMAIN_NAME}" \
  -addext "subjectAltName=DNS:${DOMAIN_NAME}"

# Install Traefik ingress controller and CRDs
helm repo add traefik https://traefik.github.io/charts
helm repo update
helm upgrade --install traefik traefik/traefik --set installCRDs=true

# Wait for CRDs to be established
kubectl wait --for=condition=Established crd/ingressroutes.traefik.io --timeout=60s

# Deploy using Helm
helm upgrade --install static-site ./charts/static-site -f charts/static-site/values.yaml \
  --set "tls.certificate=$(cat /tmp/tls.crt)" \
  --set "tls.privateKey=$(cat /tmp/tls.key)" \
  --set "tls.autoGenerate=false" \
  --set "currentEnvironment=dev"

LOCAL_IP="127.0.0.1"

# Update /etc/hosts if entry does not exist
echo "Enter your password if prompted (required for adding host to /etc/hosts)"
if ! grep -qE "^[0-9.]+\s+${DOMAIN_NAME}" /etc/hosts; then
  echo "$LOCAL_IP ${DOMAIN_NAME}" | sudo tee -a /etc/hosts
else
  sudo sed -i '' "/${DOMAIN_NAME}/d" /etc/hosts
  echo "$LOCAL_IP ${DOMAIN_NAME}" | sudo tee -a /etc/hosts
fi

echo "Starting Minikube tunnel to expose LoadBalancer services..."
echo "Enter your password if prompted (required for network changes)"
nohup minikube tunnel -p "${CLUSTER_NAME}" --cleanup=true > /tmp/minikube-tunnel.log 2>&1 &

echo "Minikube tunnel started in the background"
echo "Waiting for LoadBalancer to get external IP..."
sleep 3

# Check if external IP is assigned
EXTERNAL_IP=$(kubectl get svc traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
if [ -n "$EXTERNAL_IP" ]; then
  echo "LoadBalancer assigned external IP: $EXTERNAL_IP"
  echo "Site should be accessible at https://${DOMAIN_NAME}"
else
  echo "Warning: LoadBalancer still pending. Run 'minikube tunnel -p ${CLUSTER_NAME}' manually."
fi
