provider "google" {
  project = var.project
  region  = var.region
}

data "google_client_config" "default" {}

resource "google_container_cluster" "primary" {
  name     = "static-site-gke-${var.stage}"
  location = var.region
  initial_node_count = 1

  node_config {
    machine_type = "e2-medium"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool-${var.stage}"
  cluster    = google_container_cluster.primary.name
  location   = var.region
  node_count = 1

  node_config {
    preemptible  = false
    machine_type = "e2-medium"
  }
}

provider "kubernetes" {
  host                   = google_container_cluster.primary.endpoint
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

provider "helm" {
  kubernetes {
    host                   = google_container_cluster.primary.endpoint
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
    token                  = data.google_client_config.default.access_token
  }
}

resource "helm_release" "static_site" {
  name       = "static-site-${var.stage}"
  chart      = "../../charts/static-site"
  namespace  = var.namespace
  set {
    name  = "currentEnvironment"
    value = var.stage
  }
}

resource "helm_release" "traefik" {
  name       = "traefik-${var.stage}"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  version    = "24.0.0"
  namespace  = var.namespace
}
