# Real-Time Fraud Detection Lab

Real-time fraud detection platform lab with Terraform, Kubernetes, Kafka, Spark, Redis and Cassandra.

PT-BR: laboratorio de engenharia de dados para simular uma plataforma de deteccao de fraude em tempo real.

## Overview

This project models a streaming fraud-detection platform and shows how data infrastructure components fit together in a reproducible local lab.

## Stack

- Terraform
- Kubernetes / kind
- Kafka
- Spark
- Redis
- Cassandra

## Architecture

- Terraform provisions the local infrastructure.
- Kafka represents the streaming ingestion layer.
- Spark handles stream processing and analytical logic.
- Redis and Cassandra support low-latency and persistent data access patterns.

## Setup

```bash
terraform init
terraform plan
terraform apply
```

Use the files in this repository as the source of truth for provider, module and local cluster configuration.

## Usage

Deploy the lab locally, inspect the provisioned services, and use it as a reference architecture for real-time data engineering experiments.

## Project Status

`active` / `portfolio`

This is a primary portfolio project for data engineering and infrastructure-heavy analytics.

## Roadmap

- Add sample event generator and fraud scoring flow.
- Add architecture diagram.
- Add smoke-test script for local deployment.
