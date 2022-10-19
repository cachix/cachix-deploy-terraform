A Terraform module that launches the Cachix Deploy agent on new NixOS machines.

## Examples

* [Amazon Web Services](examples/aws.tf)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
|target\_host | The host address of the target machine to deploy to | `string` | n/a | yes |
|agent\_name | The name of the agent to deploy | `string` | n/a | yes |
|agent\_token | A path to the agent authentication token | `string` | `cachix-agent.token` | no |
|ssh\_private\_key | The private SSH key used to connect to the target\_host | `string` | `""` | no |
|ssh\_private\_key\_file | A path to the private SSH key used to connect to the target\_host | `string` | `""` | no |
