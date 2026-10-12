terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.9.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "azurerm" {
    resource_group_name = "rg-tfstate"
    storage_account_name = "sttfstate25790"
       container_name = "tfstate"
    key = "dev.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

locals {
common_tags = {
  environment = var.environment
    managed_by  = "terraform"
  }
}

resource "azurerm_resource_group" "main" {
  name     = "rg-demo-${var.environment}"
  location = var.location

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }


}
