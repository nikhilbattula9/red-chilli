terraform {

  # Provider
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  # Backend to store Terraform state. You can use Azure Storage Account or Terraform Cloud and so on for it.
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-prod-eus-001"
    storage_account_name = "sttfstateprodeus001"
    container_name       = "terraformstate"
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
