#!/bin/bash

# Enable logging for debugging
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=== User Data Script Started at $(date) ==="
set -e

# Function to handle errors
error_exit() {
    echo "ERROR: $1" >&2
    exit 1
}

# Update system
echo "=== Updating system ==="
apt-get update -y || error_exit "Failed to update package list"
apt-get upgrade -y || error_exit "Failed to upgrade packages"

# Install dependencies
echo "=== Installing dependencies ==="
apt-get install -y apt-transport-https ca-certificates curl software-properties-common unzip || error_exit "Failed to install dependencies"

# Install Docker
echo "=== Installing Docker ==="
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - || error_exit "Failed to add Docker GPG key"
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu jammy stable" || error_exit "Failed to add Docker repository"
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io || error_exit "Failed to install Docker"

# Enable Docker for ubuntu user
usermod -aG docker ubuntu

# Install docker-compose globally
echo "=== Installing docker-compose ==="
curl -SL "https://github.com/docker/compose/releases/download/v2.24.1/docker-compose-linux-x86_64" \
    -o /usr/local/bin/docker-compose || error_exit "Failed to download docker-compose"
chmod +x /usr/local/bin/docker-compose
docker-compose version || error_exit "Docker Compose not working"

# Base directory for deployments
DEPLOY_BASE="/var/www/html"
mkdir -p "$DEPLOY_BASE"
cd "$DEPLOY_BASE"

# Create external network
echo "=== Creating external network ==="
docker network create app-network || echo "Network app-network already exists"

# Function to deploy a service
deploy_service() {
    local svc="$1"
    echo "=== Deploying $svc ==="
    cd "$DEPLOY_BASE/$svc"
    docker-compose pull || error_exit "Failed to pull $svc image"
    docker-compose up -d || error_exit "Failed to start $svc"
}

########################################
# POSTGRES
########################################
if [ "${deploy_postgres}" = "true" ]; then
  echo "=== Setting up PostgreSQL ==="
  mkdir -p /var/www/html/postgres
  cat > /var/www/html/postgres/docker-compose.yml <<'EOL'
version: '3.8'
services:
  postgres_5431:
    image: postgres:15
    container_name: postgres
    restart: always
    environment:
      - POSTGRES_PASSWORD=QM9k8WegDV7Ig3dZ
      - POSTGRES_USER=postgres
      - POSTGRES_DB=postgres
    ports:
      - "5431:5431"
    command: ["postgres", "-p", "5431"]
    volumes:
      - postgres_5431_data:/var/lib/postgresql/data
    networks:
      - app-network
volumes:
  postgres_5431_data:
networks:
  app-network:
    external: true
EOL
  deploy_service "postgres"
fi

########################################
# REDIS
########################################
if [ "${deploy_redis}" = "true" ]; then
  echo "=== Setting up Redis ==="
  mkdir -p /var/www/html/redis
  cat > /var/www/html/redis/docker-compose.yml <<'EOL'
version: '3.8'
services:
  redis:
    image: redis:7.2
    container_name: redis
    command: redis-server --requirepass P3VwEgM9H3NAxBG4eGVgp36Fd
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    restart: unless-stopped
    networks:
      - app-network
volumes:
  redis-data:
networks:
  app-network:
    external: true
EOL
  deploy_service "redis"
fi

########################################
# NEO4J
########################################
if [ "${deploy_neo4j}" = "true" ]; then
  echo "=== Setting up Neo4j ==="
  mkdir -p /var/www/html/neo4j
  cat > /var/www/html/neo4j/docker-compose.yml <<'EOL'
version: '3.8'
services:
  neo4j:
    image: neo4j:5.14
    container_name: neo4j
    environment:
      - NEO4J_AUTH=neo4j/9URFX00aRjebj5e1
    ports:
      - "7474:7474"
      - "7687:7687"
    volumes:
      - neo4j-data:/data
    restart: unless-stopped
    networks:
      - app-network
volumes:
  neo4j-data:
networks:
  app-network:
    external: true
EOL
  deploy_service "neo4j"
fi

########################################
# KAFKA
########################################
if [ "${deploy_kafka}" = "true" ]; then
  echo "=== Setting up Kafka ==="
  mkdir -p /var/www/html/kafka
  cat > /var/www/html/kafka/kafka.env <<'EOL'
KAFKA_CFG_NODE_ID=0
KAFKA_CFG_PROCESS_ROLES=controller,broker
KAFKA_CFG_CONTROLLER_QUORUM_VOTERS=0@kafka:9093
KAFKA_CFG_LISTENERS=SASL_PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093
KAFKA_CFG_ADVERTISED_LISTENERS=SASL_PLAINTEXT://localhost:9092
KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,SASL_PLAINTEXT:SASL_PLAINTEXT
KAFKA_CFG_CONTROLLER_LISTENER_NAMES=CONTROLLER
KAFKA_CFG_INTER_BROKER_LISTENER_NAME=SASL_PLAINTEXT
KAFKA_CFG_SASL_ENABLED_MECHANISMS=PLAIN
KAFKA_CFG_SASL_MECHANISM_INTER_BROKER_PROTOCOL=PLAIN
KAFKA_CLIENT_USERS=kafka
KAFKA_CLIENT_PASSWORDS=b43nUheaPRoJdhQ
KAFKA_CONTROLLER_USER=kafka
KAFKA_CONTROLLER_PASSWORD=b43nUheaPRoJdhQ
KAFKA_INTER_BROKER_USER=kafka
KAFKA_INTER_BROKER_PASSWORD=b43nUheaPRoJdhQ
KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1
KAFKA_CFG_DELETE_TOPIC_ENABLE=true
EOL
  cat > /var/www/html/kafka/docker-compose.yml <<'EOL'
version: '3.8'
services:
  kafka:
    image: bitnami/kafka:3.5.1-debian-11-r25
    container_name: kafka
    restart: unless-stopped
    ports:
      - "9092:9092"
      - "9093:9093"
    volumes:
      - kafka-data:/bitnami
    env_file:
      - kafka.env
    networks:
      - app-network
volumes:
  kafka-data:
networks:
  app-network:
    external: true
EOL
  deploy_service "kafka"
fi

########################################
# RABBITMQ
########################################
if [ "${deploy_rabbitmq}" = "true" ]; then
  echo "=== Setting up RabbitMQ ==="
  mkdir -p /var/www/html/rabbitmq
  cat > /var/www/html/rabbitmq/docker-compose.yml <<'EOL'
version: '3.8'
services:
  rabbitmq:
    image: rabbitmq:3.12-management
    container_name: rabbitmq
    environment:
      - RABBITMQ_DEFAULT_USER=admin
      - RABBITMQ_DEFAULT_PASS=IHb730f1i3Y3
    ports:
      - "5672:5672"
      - "15672:15672"
    volumes:
      - rabbitmq-data:/var/lib/rabbitmq
    restart: unless-stopped
    networks:
      - app-network
volumes:
  rabbitmq-data:
networks:
  app-network:
    external: true
EOL
  deploy_service "rabbitmq"
fi

echo "=== User Data Script Completed at $(date) ==="