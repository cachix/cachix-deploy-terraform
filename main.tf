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
  description = "Path to the agent token"
  default     = "cachix-agent.token"
}

variable "ssh_private_key" {
  type        = string
  description = "Content of the private key used to connect to the target_host"
  default     = ""
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
    content     = file(var.agent_token)
    destination = "/etc/cachix-agent.token"
  }

  provisioner "remote-exec" {
    inline = [
      "echo Installing cachix...",
      "nix-env -iA cachix -f https://cachix.org/api/v1/install",
      # Remove once switched to release
      "cachix --host https://stagix.org use cachix-sandydoo --mode root-nixconf",

      "echo Copying over the agent token",
      "export $(cat /etc/cachix-agent.token)",

      "echo Launching agent",
      # "cachix deploy agent ${var.agent_name} --bootstrap"
      "nix run github:sandydoo/cachix/feature/455 --extra-experimental-features nix-command --extra-experimental-features flakes -- --host https://stagix.org deploy agent ${var.agent_name} --bootstrap",
    ]
  }
}
