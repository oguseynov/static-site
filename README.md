# Static Site with Traefik

This Helm chart deploys a static website using Nginx and Traefik as the Ingress Controller. It supports both development (with self-signed certificates) and production (with Let's Encrypt) environments.

## Prerequisites

- Kubernetes cluster
- Helm installed
- Traefik installed as Ingress Controller
- minikube and docker for local development

## Deployment

### Local Development (minikube)

1. Run the setup script:
   ```sh
   ./scripts/setup-minikube.sh
   ```
2. Access the site at https://dev.local in your browser, or run:
   ```sh
   curl -v https://dev.test --insecure
   ```
3. To clean up resources created with `setup-minikube.sh`:
   ```sh
   pkill -f "minikube tunnel -p static-site"
   minikube delete -p static-site
   ```

### Production (GKE with Terraform & Terragrunt)

See `terraform/prod`. (Note: Not tested, missing backend for remote state.)

With Terraform and Terragrunt installed, deploy with:

```sh
cd terraform/prod
terragrunt init
terragrunt apply
```
