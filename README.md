# Project Name

This repository uses **Terraform** to provision and manage infrastructure on **Microsoft Azure**, with automation through **Azure DevOps CI/CD pipelines**.

## Overview

- **Terraform** for Infrastructure as Code (IaC)
- **Azure DevOps** for Continuous Integration and Deployment (CI/CD)
- Modular design: bootstrap for state management, resources for main infrastructure

## Features

- Modular Terraform codebase for easy maintenance and scalability
- Separation of bootstrap (state storage) and main resource modules
- Automated CI/CD pipelines with Azure DevOps
- Secure remote state storage in Azure
- Automatic pipeline triggers on resource changes
- Manual pipeline for initial state backend provisioning
- Supports infrastructure updates via code commits

## Project Structure

```
.
├── terraform/
│   ├── bootstrap/        # Terraform .tf files for state storage infrastructure (e.g., Azure Storage Account, containers, etc.)
│   └── resources/        # Terraform .tf files for main Azure infrastructure resources
├── azure-pipeline-resources.yml    # Azure DevOps pipeline for main resources deployment
├── azure-pipelines-bootstrap.yml   # Azure DevOps pipeline for bootstrap deployment
└── README.md
```

### terraform/bootstrap/

```
bootstrap.tf
providers.tf
var.tf
```

### terraform/resources/

```
databricks_ws.tf
datafactory.tf
endpoint_backend.tf
endpoint_dbfs.tf
endpoint_frontend.tf
endpoint_webauth.tf
keyvault.tf
main.tf
private_dns_zone_dp.tf      # (dp = databricks data plane)
private_dns_zone_transit.tf
providers.tf
storage.tf
var.tf
vnet_dp.tf                 # (dp = databricks data plane)
vnet_transit.tf
```

- **terraform/bootstrap/**: Contains Terraform code to provision resources needed for storing the Terraform state file securely (such as an Azure Storage Account and blob container).  
  Deploy this module first, as it is required for state management.
- **terraform/resources/**: Contains Terraform code for your main Azure infrastructure (e.g., VMs, networks, databases, Databricks, etc.).

## CI/CD Workflow

### Bootstrap Pipeline

- **File:** `azure-pipelines-bootstrap.yml`
- **Purpose:** Provision resources needed for storing the Terraform state file (e.g., Azure Storage Account, blob container).
- **Trigger:** Run manually once when setting up the project.  
  This pipeline is not intended for automatic execution, except if you need to update state storage infrastructure.
- **Note:** Run this pipeline before running any other Terraform deployments.

### Main Resources Pipeline

- **File:** `azure-pipeline-resources.yml`
- **Purpose:** Deploy and manage the main Azure infrastructure (VMs, networks, databases, etc.).
- **Trigger:** Runs automatically on changes to files in the `terraform/resources/` directory.
- **Workflow:**  
  1. Checkout repository  
  2. Initialize Terraform with backend configured in bootstrap  
  3. Plan changes (`terraform plan`)  
  4. Apply changes (`terraform apply`, with optional approvals)  
  5. Store state securely in the backend

---

## Prerequisites

Before you begin, ensure you have the following:

- An [Azure account](https://portal.azure.com/) with sufficient permissions to provision resources (Storage Account, Resource Group, etc.)  
  **Note:** You also need permission to create a Service Principal in Azure. The required role is typically **Application Administrator** or **Owner** in the subscription or directory.
- An [Azure DevOps](https://dev.azure.com/) organization and project set up
- [Terraform](https://www.terraform.io/downloads.html) installed locally
- [Git](https://git-scm.com/) installed locally
- An Azure **Service Principal** created for Terraform deployments  
  ([How to create a Service Principal](https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure))
- A Service Connection in Azure DevOps configured with the Service Principal credentials
- **Variable Groups** configured in Azure DevOps for storing Terraform variables and secrets  
  ([Variable Groups documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups))
- Access to the Azure DevOps repository for this project

---

## Getting Started

### Scenario 1: Initialize and Push Local Repo to Azure DevOps

1. **Initialize a local git repository (if not already initialized):**
   ```sh
   git init
   git add .
   git commit -m "Initial commit"
   ```
2. **Add Azure DevOps remote:**
   ```sh
   git remote add origin https://dev.azure.com/{organization}/{project}/_git/{repo}
   ```
3. **Push your code to Azure DevOps:**
   ```sh
   git push -u origin main
   ```
4. **Go to Azure DevOps portal and manually run the bootstrap pipeline:**
   - Navigate to Pipelines > Bootstrap Pipeline
   - Click **Run pipeline** to provision state storage

5. **Make changes in the `terraform/resources/` directory to trigger the main resources pipeline:**
   ```sh
   # Edit or add files in terraform/resources/
   git add terraform/resources/
   git commit -m "Add main infrastructure resources"
   git push
   ```
   - The main resources pipeline in Azure DevOps will run automatically on changes pushed to this directory.

---

### Scenario 2: Clone Existing Azure DevOps Repo and Work With Pipelines

1. **Clone the repository from Azure DevOps:**
   ```sh
   git clone https://dev.azure.com/{organization}/{project}/_git/{repo}
   cd {repo}
   ```
2. **If the bootstrap pipeline has not run before, manually trigger it:**
   - Go to Azure DevOps portal
   - Navigate to Pipelines > Bootstrap Pipeline
   - Click **Run pipeline** to provision state storage

3. **Wait until the manual bootstrap pipeline completes. Then, make changes as needed and push them. The main resources pipeline in Azure DevOps will run automatically on changes pushed to the `terraform/resources/` directory.**
   ```sh
   git add .
   git commit -m "Your change message"
   git push
   ```

---

**Note:**  
- The bootstrap pipeline is a one-time, manual run for setting up Terraform state storage.
- The resources pipeline runs automatically on code changes to main infrastructure files.

## Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Azure DevOps Documentation](https://docs.microsoft.com/en-us/azure/devops/)
- [Azure Provider for Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).