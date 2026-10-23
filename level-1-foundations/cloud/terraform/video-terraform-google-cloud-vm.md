# Terraform on Google Cloud (GCP)

## Overview & Prerequisites
* **Objective:** Learn how to provision a Virtual Machine (Compute Engine instance) on Google Cloud Platform (GCP) using Terraform, while comparing the process with AWS.
* **GCP Setup Requirements:**
  * Active GCP account (using the Free Tier, such as `e2-micro` instances).
  * Project creation (e.g., named "Alura" with a unique project ID).
  * Compute Engine API enabled.
  * Dedicated Service Account configured with `Project > Editor` role permissions.
  * Service account key created and downloaded securely as a JSON file (e.g., `chave.json`), treating it as sensitive data and avoiding version control exposure.

## Writing the Configuration (`main.tf`)
* **Provider Configuration:** Declares the HashiCorp Google provider version and authentication parameters:
```hcl
  terraform {
    required_providers {
      google = {
        source  = "hashicorp/google"
        version = "3.5.0"
      }
    }
  }

  provider "google" {
    credentials = file("chave.json")
    project     = "<PROJECT_ID>"
    region      = "us-central1"
    zone        = "us-central1-c"
  }
  ```

  * **Resource Provisioning (`google_compute_instance`):** Defines the virtual machine details, network configuration, and startup script:
  * **Naming Rule:** GCP resource names must be lowercase (`[a-z0-9]`).
  * **Instance Type:** `e2-micro` (free tier compatible).
  * **Boot Disk:** Configured with an image (e.g., Debian 9).
  * **Network:** Uses default network configuration with an ephemeral public IP (`access_config`).
  * **Startup Script:** Executes initialization commands upon creation (e.g., `metadata_startup_script = "echo oi > /teste.txt"`).

## Terraform Lifecycle & Execution Commands
* `terraform init`: Initializes the project directory, downloads required provider plugins, and prepares the backend.
* `terraform apply`: Generates an execution plan, displays the changes (`Plan: 1 to add...`), and provisions the resources upon confirmation (`yes`).
* `terraform destroy`: Safely tears down and deletes all provisioned cloud infrastructure to prevent ongoing costs.

## Key Differences: GCP vs. AWS
* **Authentication:** AWS typically uses CLI configuration (`aws configure`), whereas GCP relies on service account JSON key files.
* **Resource Naming & Structure:** AWS uses `aws_instance` (EC2) with AMI references, while GCP uses `google_compute_instance` (Compute Engine) configured via image strings and explicit zone definitions.
* **Networking & Metadata:** GCP requires explicit network interface definitions (`network_interface`), whereas AWS provisions default networking automatically. GCP startup scripts are also more straightforward to define via strings compared to AWS multi-line EOF blocks.