<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | 0.14.5 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alternative\_names | Alternative Domain Names | `list(string)` | n/a | yes |
| domain\_name | Domain Name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cert\_status | Status of the certificate |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
