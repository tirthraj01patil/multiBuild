# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.gcp_cluster}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.gcp_cluster}-subnet"
  region        = var.gcp_region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}