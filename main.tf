variable "target_host" {
  type        = string
  description = "The host to deploy to"
}

variable "agent_name" {
  type        = string
  description = "The name of the agent"
}

variable "agent_token" {
  type        = string
  description = "The agent auth token"
  sensitive   = true
}

variable "agent_profile" {
  type        = string
  description = "The Nix profile for the agent to manage"
  default     = ""
}

variable "cachix_host" {
  type        = string
  description = "The host for the Cachix Deploy service"
  default     = "https://cachix.org"
}

variable "binary_cache_name" {
  type        = string
  description = "The name of the binary cache to use"
}

variable "ssh_private_key" {
  type        = string
  description = "Content of the private key used to connect to the target_host"
  default     = ""
  sensitive   = true
}

variable "ssh_private_key_file" {
  type        = string
  description = "Path to the private key used to connect to the target_host"
  default     = ""
}

locals {
  ssh_private_key = var.ssh_private_key == "" ? file(var.ssh_private_key_file) : var.ssh_private_key
}

resource "null_resource" "cachix_deploy" {
  connection {
    type        = "ssh"
    host        = var.target_host
    port        = 22
    user        = "root"
    agent       = false
    timeout     = "100s"
    private_key = local.ssh_private_key
  }

  provisioner "file" {
    content     = "CACHIX_AGENT_TOKEN=${var.agent_token}"
    destination = "/etc/cachix-agent.token"
  }

  provisioner "file" {
    source      = "${path.module}/bootstrap-agent.sh"
    destination = "/tmp/bootstrap-agent.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap-agent.sh",
      "/tmp/bootstrap-agent.sh ${var.cachix_host} ${var.binary_cache_name} ${var.agent_name} ${var.agent_profile}"
    ]
  }
}
