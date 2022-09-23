provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "example" {
  ami           = "ami-00badba5cfa0a0c0d"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name = "CachixTerraform"
  vpc_security_group_ids = [
    "sg-06aaaf1a5a289554b"
  ]
}

module "cachix_deploy" {
  source      = "../"
  target_host = aws_instance.example.public_ip
  agent_name = "cachix-terraform"
  ssh_private_key = "CachixTerraform.pem"
}

