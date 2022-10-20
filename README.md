A Terraform module to adopt NixOS machines into Cachix Deploy.

> Cachix Deploy is a continuous deployment service for Nix profiles.
> Learn more at https://docs.cachix.org/deploy/

This module is provider-agnostic. It uses `remote-exec` to bootstrap the Cachix Deploy agent on the target host over SSH. This is considered a [last resort approach in Terraform](https://www.terraform.io/language/resources/provisioners/syntax#provisioners-are-a-last-resort), which is why we strongly recommend using our Cachix Deploy images when possible:

| Provider | Images | Tutorial |
|----------|--------|----------|
| Amazon Web Services (AWS) | https://github.com/cachix/cachix-deploy-amis/ | https://github.com/cachix/cachix-deploy-aws |

# Requirements

You'll need:

* Nix already installed on the target host.
* SSH access to the target host.

## Examples

```terraform
module "cachix_deploy" {
  source          = "github.com/sandydoo/cachix-deploy-terraform"
  target_host     = aws_instance.machine.public_ip
  agent_name      = "cachix-terraform"
  agent_token     = "cachix-agent.token"
  ssh_private_key = tls_private_key.state_ssh_key.private_key_openssh
}
```

Full examples for various providers:

* [Amazon Web Services (AWS)](examples/aws.tf)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| target\_host | The host address of the target machine to deploy to | `string` | n/a | yes |
| agent\_name | The name of the agent to deploy | `string` | n/a | yes |
| agent\_token | The agent authentication token | `string` | n/a | yes |
| agent\_profile | The name the profile for the agent to manage. Defaults to `system`. | `string` | `""` | no |
| ssh\_private\_key | The private SSH key used to connect to the target\_host | `string` | `""` | no |
| ssh\_private\_key\_file | A path to the private SSH key used to connect to the target\_host | `string` | `""` | no |
| cachix\_host | The host for the Cachix Deploy service | `string` | `https://cachix.org` | no |
