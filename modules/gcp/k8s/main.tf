terraform {
  required_version = ">= 1.11.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}


provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

#Fetch current GCP client config (auth context)

data "google_client_config" "default" {}

#Connects Terraform’s Kubernetes provider to your GKE cluster
provider "kubernetes" {
  host = google_container_cluster.primary.endpoint

  token = data.google_client_config.default.access_token

  cluster_ca_certificate = base64decode(
    google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  )
}