variable "target_host" {
  type        = string
  description = "The host to deploy to"
}

variable "agent_name" {
  type = string
  description = "The name of the agent"
}

variable "agent_token" {
  type        = string
  description = "Path to the agent token"
  default     = "cachix-agent.token"
}

variable "ssh_private_key" {
  type = string
  description = "SSH private key"
}

resource "null_resource" "cachix_deploy" {

  connection {
    type        = "ssh"
    host        = var.target_host
    port        = 22
    user        = "root"
    agent       = false
    timeout     = "100s"
    private_key = file(var.ssh_private_key)
  }

  provisioner "file" {
    content     = file(var.agent_token)
    destination = "/etc/cachix-agent.token"
  }

  provisioner "remote-exec" {
    inline = [
      "nix-env -iA cachix -f https://cachix.org/api/v1/install",
      "export $(cat /etc/cachix-agent.token)",
      "cachix deploy agent ${var.agent_name}"
    ]
  }
}
