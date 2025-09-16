#=============================================================== 
# Kubernetes
#===============================================================

# AWS

project                  = "project"
region                   = "us-east-1"
aws_access_key           = ""
aws_secret_key           = ""
desired_size             = 3
max_size                 = 5
min_size                 = 3
vpc_cidr                 = "10.1.0.0/16"
availability_zones_count = 2
subnet_cidr_bits         = 8
tags = {
  Environment = "dev"
  Owner       = "team"
}



deploy_postgres_aws_k8s = true
deploy_redis_aws_k8s    = true
deploy_kafka_aws_k8s    = true
deploy_rabbitmq_aws_k8s = true
deploy_neo4j_aws_k8s    = true
deploy_argocd_aws_k8s   = true
deploy_elasticsearch_aws_k8s= true
deploy_cassandra_aws_k8s    = true


# Azure

project_name     = "harshal-stage"
azure_node_count = 3
azure_region     = "eastus"
appId            = ""
password         = ""
azure_vm_size    = "Standard_DS2_v2"

# Databases
deploy_postgres_azure_k8s      = true
deploy_redis_azure_k8s         = true
deploy_kafka_azure_k8s         = true
deploy_rabbitmq_azure_k8s      = true
deploy_neo4j_azure_k8s         = true
deploy_argocd_azure_k8s        = true
deploy_elasticsearch_azure_k8s = true
deploy_cassandra_azure_k8s     = true


# GCP

gcp_project_id = "harshal-stage"
gcp_cluster    = "harshal-stage"
gcp_region     = "us-east1-b"
gke_num_nodes  = "3"

deploy_postgres_gcp_k8s = true
deploy_redis_gcp_k8s    = true
deploy_kafka_gcp_k8s    = true
deploy_rabbitmq_gcp_k8s = true
deploy_neo4j_gcp_k8s    = true
deploy_argocd_gcp_k8s       = true
deploy_elasticsearch_gcp_k8s = true
deploy_cassandra_gcp_k8s     = true


#=============================================================
# Server
#===============================================================


# AWS

project_name_server   = "aws-server"
region_server         = "ap-south-1"
aws_access_key_server = ""
aws_secret_key_server = ""
instance_type_server  = "c5.xlarge"

deploy_postgres_aws = false
deploy_redis_aws    = false
deploy_kafka_aws    = false
deploy_rabbitmq_aws = true
deploy_neo4j_aws    = true


# Azure

appId_server    = ""
password_server = ""
project_server  = "azure-server"
size_server     = "Standard_B2s"
location_server = "East US"

deploy_postgres_azure = true
deploy_redis_azure    = false
deploy_kafka_azure    = false
deploy_rabbitmq_azure = false
deploy_neo4j_azure    = false


# GCP

project_id    = ""
region-gcp    = "us-central1"
zone-gcp      = "us-central1-a"
instance_name = "gcp-server"
machine_type  = "e2-medium"
username_gcp  = "root"

deploy_postgres_gcp = true
deploy_redis_gcp    = true
deploy_kafka_gcp    = true
deploy_rabbitmq_gcp = true
deploy_neo4j_gcp    = true


# hetzner

hcloud_token = ""
server_name  = "hetzner-server"
server_type  = "cpx31"
location     = "fsn1"

deploy_postgres_hetzner = false
deploy_redis_hetzner    = false
deploy_kafka_hetzner    = true
deploy_rabbitmq_hetzner = false
deploy_neo4j_hetzner    = false