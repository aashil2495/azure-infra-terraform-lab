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

## Setup Instructions
Follow these steps to replicate the demo:

1. **Access Azure DevOps**:
   - Navigate to [Azure DevOps](https://dev.azure.com/itm9).
   - Create a new project or select an existing one.

2. **Set Up Repository**:
   - Go to **Repos** in your Azure DevOps project.
   - If a repository exists, use it. Otherwise, create a new one by clicking the **+** symbol next to the project name and providing a name, then click **Create**.

3. **Clone Repositories Locally**:
   - On your local machine, navigate to the desired folder for the GitHub repository.
   - Clone the GitHub repository:
     ```bash
     git clone https://github.com/jatinitm/a_iac_terraform_dbrx.git
     ```
   - Sign in when prompted to complete the cloning process.
   - Navigate to the folder where you want to create the local Azure DevOps repository.
   - Clone your Azure DevOps repository (replace `{your repo name}` with your repository name):
     ```bash
     git clone https://{your organization name}@dev.azure.com/{your organization name}/{your project name}/_git/{your repo name}
     ```

4. **Copy Files**:
   - Copy all files from the cloned GitHub repository folder to the local Azure DevOps repository folder.

5. **Work in VS Code**:
   - Open the Azure DevOps repository folder in Visual Studio Code:
     ```bash
     code .
     ```

6. **Verify and Push Changes**:
   - Verify the remote repository:
     ```bash
     git remote -v
     ```
   - Stage all files:
     ```bash
     git add .
     ```
   - Commit changes:
     ```bash
     git commit -m "Initial commit with Terraform files"
     ```
   - Push to the Azure DevOps repository:
     ```bash
     git branch -M main
     git push -u origin main
     ```

7. **Create Bootstrap Pipeline**:
   - In Azure DevOps, navigate to **Pipelines** and click **Create Pipeline**.
   - Select **Azure Repos Git** and choose your repository.
   - In the path field, select `/azure-pipelines-bootstrap.yml` to create the bootstrap pipeline.
   - Save and rename the pipeline (e.g., `bootstrap`) by clicking the three dots next to the pipeline and selecting **Rename/move**.

8. **Create Resources Pipeline**:
   - Click **Create Pipeline** again.
   - Select **Azure Repos Git** and your repository.
   - In the path field, select `/azure-pipelines-resources.yml` to create the resources pipeline.
   - Save and rename the pipeline (e.g., `resources`).

9. **Create Variable Group**:
   - Go to **Pipelines** → **Library** → **+ Variable group**.
   - Name the group `var_dev_group`.
   - Add the following variables (replace `<your tenant id>` and `<your subscription id>` with values from your Azure account):
     - `environment`: `dev`
     - `tenant_id`: `<your tenant id>`
     - `subscription_id`: `<your subscription id>`

10. **Create Service Connection**:
   - Go to **Project Settings** → **Service connections**.
   - Choose **Azure Resource Manager**.
   - Select:
     - **Identity type**: App registration
     - **Credential**: Secret
     - **Scope level**: Subscription
     - **Name**: The service principal that you have in Azure Portal.
   - Follow the prompts to configure the connection using your Azure Service Principal.

11. **Run Bootstrap Pipeline**:
   - In **Pipelines**, locate the `bootstrap` pipeline.
   - Click the three dots next to it and select **Run pipeline**.
   - Wait for the pipeline to complete.

12. **Run Resources Pipeline**:
   - Once the bootstrap pipeline completes, locate the `resources` pipeline.
   - Run it by clicking the three dots and selecting **Run pipeline**.
   - Wait for the pipeline to complete.

13. **Update Terraform Files**:
   - Make changes to any Terraform file in your local Azure DevOps repository.
   - Stage, commit, and push the changes:
     ```bash
     git add .
     git commit -m "Update Terraform configuration"
     git push origin main
     ```
   - This will trigger the `resources` pipeline, automatically deploying the updates.

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
