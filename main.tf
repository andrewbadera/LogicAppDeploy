terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.9.0"
    }
  }
}

provider "azurerm" {
    features {}
}

variable "ARM_SUBSCRIPTION_ID" {
  type = string
}

variable "COSMOS_DB_ACCOUNT" {
  type = string
}

variable "COSMOS_DB_DATABASE" {
  type = string
}

variable "COSMOS_DB_CONTAINER" {
  type = string
}

variable "RG_NAME" {
  type = string
}

variable "RG_LOCATION" {
  type = string
}

variable "LOCATION_ABBREVIATION" {
  type = string
}

variable "ENVIRONMENT" {
  type = string
}

resource "azurerm_resource_group" "rg" {
    name     = "${var.RG_NAME}"
    location = "${var.RG_LOCATION}"
}

resource "azurerm_logic_app_workflow" "logic_app_workflow" {
  location = "${var.RG_LOCATION}"
  name     = "la-ghdeploy-${var.LOCATION_ABBREVIATION}-${${var.ENVIRONMENT}}"
  parameters = {
    "$connections" = "{\"documentdb\":{\"connectionId\":\"/subscriptions/${var.ARM_SUBSCRIPTION_ID}/resourceGroups/${var.RG_NAME}/providers/Microsoft.Web/connections/documentdb\",\"connectionName\":\"documentdb\",\"connectionProperties\":{\"authentication\":{\"type\":\"ManagedServiceIdentity\"}},\"id\":\"/subscriptions/${var.ARM_SUBSCRIPTION_ID}/providers/Microsoft.Web/locations/${var.RG_LOCATION}/managedApis/documentdb\"}}"
  }
  resource_group_name = "${var.RG_NAME}"
  workflow_parameters = {
    "$connections" = "{\"defaultValue\":{},\"type\":\"Object\"}"
  }
  access_control {
    trigger {
      allowed_caller_ip_address_range = []
  }
  identity {
    type = "SystemAssigned"
  }
  depends_on = [
    azurerm_resource_group.rg,
  ]
  }
}

resource "azurerm_logic_app_action_custom" "logic_app_cosmosdb_createorupdatedocumentv3" {
  body = jsonencode({
    inputs = {
      body = "@addProperty(triggerBody(), 'id', guid())"
      host = {
        connection = {
          name = "@parameters('$connections')['documentdb']['connectionId']"
        }
      }
      method = "post"
      path   = "/v2/cosmosdb/@{encodeURIComponent('${var.COSMOS_DB_ACCOUNT}')}/dbs/@{encodeURIComponent('${var.COSMOS_DB_DATABASE}')}/colls/@{encodeURIComponent('${var.COSMOS_DB_CONTAINER}')}/docs"
    }
    runAfter = {}
    type     = "ApiConnection"
  })
  logic_app_id = "/subscriptions/${var.ARM_SUBSCRIPTION_ID}/resourceGroups/${var.RG_NAME}/providers/Microsoft.Logic/workflows/la-ghdeploy-${var.LOCATION_ABBREVIATION}-${${var.ENVIRONMENT}}"
  name         = "Create_or_update_document_(V3)"
  depends_on = [
    azurerm_logic_app_workflow.logic_app_workflow,
  ]
}

resource "azurerm_logic_app_trigger_http_request" "logic_app_trigger_http_request" {
  logic_app_id = "/subscriptions/${var.ARM_SUBSCRIPTION_ID}/resourceGroups/${var.RG_NAME}/providers/Microsoft.Logic/workflows/la-ghdeploy-${var.LOCATION_ABBREVIATION}-${${var.ENVIRONMENT}}"
  method       = "POST"
  name         = "When_a_HTTP_request_is_received"
  schema = jsonencode({
    properties = {
      alarm_detail = {
        items = {
          type = "string"
        }
        type = "array"
      }
      alarm_name = {
        type = "string"
      }
      alarm_status = {
        type = "string"
      }
      alarm_value = {
        type = "string"
      }
      alarm_value_unit = {
        type = "string"
      }
      device_ip = {
        type = "string"
      }
      device_name = {
        type = "string"
      }
      environment = {
        type = "string"
      }
      gateway_ip = {
        type = "string"
      }
      gateway_name = {
        type = "string"
      }
      message_type = {
        type = "string"
      }
      source = {
        type = "string"
      }
      timestamp = {
        type = "string"
      }
    }
    type = "object"
  })
  depends_on = [
    azurerm_logic_app_workflow.logic_app_workflow,
  ]
}

resource "azurerm_api_connection" "logic_app_api_connection" {
  managed_api_id      = "/subscriptions/${var.ARM_SUBSCRIPTION_ID}/providers/Microsoft.Web/locations/${var.RG_LOCATION}/managedApis/documentdb"
  name                = "documentdb"
  resource_group_name = "${var.RG_NAME}"
  depends_on = [
    azurerm_resource_group.rg,
  ]
}
