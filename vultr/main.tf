terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "2.21.0"
    }
  }
}

provider "vultr" {
  api_key     = "${var.VULTR_API_KEY}"
}

variable "VULTR_API_KEY" {
  nullable = false
}

variable "firewall_group_id" {
  type     = string
  nullable = false
}

variable "prefix" {
  type     = string
  nullable = false
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9]*$", var.prefix))
    error_message = "Invalid prefix."
  }
}

variable "region" {
  type     = string
  nullable = false 
}

variable "ssh_public_key" {
  type = string
  nullable = false
}

variable "tag" {
  type = string
  nullable = false
}

resource "vultr_ssh_key" "root_ssh_key" {
  name    = "SSH Key (${var.prefix})"
  ssh_key = file("${var.ssh_public_key}")
}

resource "vultr_startup_script" "ipxeNodes" {
  name   = "trainingNodePxeBoot (${var.prefix})"
  script = filebase64("${path.module}/files/ipxe_script")
  type   = "pxe"
}
