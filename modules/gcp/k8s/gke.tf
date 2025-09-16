# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${var.gcp_cluster}-gke"
  location = var.gcp_region
  ip_allocation_policy {
  }
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  # remove_default_node_pool = true
  initial_node_count = 1
  # enable_autopilot = true

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name              = google_container_cluster.primary.name
  location          = var.gcp_region
  cluster           = google_container_cluster.primary.name
  node_count        = var.gke_num_nodes
  max_pods_per_node = "32"

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.gcp_cluster
    }

    # preemptible  = true
    machine_type = "n1-standard-8"
    tags         = ["gke-node", "${var.gcp_cluster}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }

  }
}