provider "aws" {
  region = "eu-west-1"
}

# TODO: which AMI repo is maintained?
# module "nixos_image" {
#   source  = "git::https://github.com/numtide/terraform-nixos-amis.git?ref=645471853e0a9083865b0da2e341f133bf26a5f2"
#   release = "latest"
# }

resource "aws_security_group" "ssh_and_egress" {
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# This key is stored unencrypted in the Terraform state file.
# For production, provide you own key!
resource "tls_private_key" "state_ssh_key" {
  algorithm = "RSA"
}

resource "local_sensitive_file" "machine_ssh_key" {
  content         = tls_private_key.state_ssh_key.private_key_pem
  filename        = "${path.module}/id_rsa.pem"
  file_permission = "0600"
}

resource "aws_key_pair" "generated_key" {
  key_name   = "generated-key-${sha256(tls_private_key.state_ssh_key.public_key_openssh)}"
  public_key = tls_private_key.state_ssh_key.public_key_openssh
}

resource "aws_instance" "machine" {
  # ami                  = module.nixos_image.id
  ami                    = "ami-00badba5cfa0a0c0d"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ssh_and_egress.id]
  key_name               = aws_key_pair.generated_key.key_name
  root_block_device {
    volume_size = 50 # GiB
  }
}

module "cachix_deploy" {
  source          = "../"
  target_host     = aws_instance.machine.public_ip
  agent_name      = "cachix-terraform"
  # TODO: remove
  agent_token     = "stagix-agent.token"
  ssh_private_key = tls_private_key.state_ssh_key.private_key_openssh
}

output "public_dns" {
  value = aws_instance.machine.public_dns
}

