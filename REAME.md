# Static Site with Traefik

This Helm chart deploys a static website using Nginx and Traefik as the Ingress Controller. It supports both development (with self-signed certificates) and production (with Let's Encrypt) environments.

## Prerequisites

- Kubernetes cluster
- Helm installed
- Traefik installed as Ingress Controller
- minikube and docker for local development)

## Deployment

### Development (minikube)

1. Run [setup-minikube.sh](scripts/setup-minikube.sh):

   ```bash
   ./scripts/setup-minikube.sh
   ```
2. Access the site at https://dev.local through browser or run the following curl command:
   ```bash
    curl -v https://dev.test --insecure
   ```
3. To clean up resources created with `setup-minikube.sh`:
   ```bash
   pkill -f "minikube tunnel -p static-site"
   minikube delete -p static-site
   ```

### Production
1. Ensure you have a domain name pointing to your cluster.
2. Set useSelfSigned to false in values.yaml.
3. Configure Traefik with Let's Encrypt as per Traefik's documentation.
4. Deploy the chart:
   ```bash
   helm upgrade --install static-site ./charts/static-site --values charts/static-site/values.yaml
   ```
