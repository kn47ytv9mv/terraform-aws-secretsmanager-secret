# terraform-aws-secretsmanager-secret

Terraform module for a Secrets Manager secret.

## Cost

Secrets Manager bills a flat monthly fee per secret, plus a
per-10,000-API-calls charge for retrieving it. See AWS's
[Secrets Manager pricing](https://aws.amazon.com/secrets-manager/pricing/)
page for current rates.

## Design

Two ways to set the secret's initial value, and the choice matters for
real security reasons, not just style:

- **`secret_value`** — a plain string, persisted in Terraform state
  like any other value. Simple, and fine for a secret state access is
  already restricted for (a private repository, a properly access-
  controlled remote backend) — but the value sits in plaintext in
  state either way.
- **`secret_value_wo`** — Terraform's write-only attribute support:
  the value is sent to AWS during apply and never written to state at
  all. Pair with `secret_value_wo_version`, bumped by the caller
  whenever the value actually changes — Terraform has no copy of a
  write-only value to diff against, so the version number is the only
  signal it has that something changed. Needs Terraform 1.11 or newer.

Leave both null to create the secret with no initial version at all —
a valid state for a secret a rotation Lambda populates after creation,
rather than one this module seeds directly.

`recovery_window_in_days` can be set to `0` for immediate, unrecoverable
deletion — appropriate for a genuinely disposable secret (test/dev
credentials recreated on every apply), never for anything a real
rollback might depend on recovering.

## Usage

```hcl
module "db_password" {
  source = "kn47ytv9mv/secretsmanager-secret/aws"

  description  = "Database password for the app service."
  secret_value = random_password.db.result
}
```

Or directly from this repository, using the write-only path so the
value never touches state:

```hcl
module "db_password" {
  source = "github.com/kn47ytv9mv/terraform-aws-secretsmanager-secret"

  description             = "Database password for the app service."
  kms_key_id               = module.kms_key.arn
  secret_value_wo          = var.db_password
  secret_value_wo_version  = 1
}
```

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.11 |
| aws | ~> 6.61 |
| random | ~> 3.9 |

## Providers

| Name | Version |
|---|---|
| aws | ~> 6.61 |
| random | ~> 3.9 |

## Inputs

| Name | Description | Default | Required |
|---|---|---|---|
| name | Name of the secret. If null, a unique name is generated. | `null` | no |
| description | A description of the secret. | `null` | no |
| kms_key_id | ARN or ID of a KMS key to encrypt the secret with. If null, AWS's own managed key ('aws/secretsmanager') is used. | `null` | no |
| policy | IAM resource policy document (JSON) controlling access to the secret, for cross-account access or an explicit deny. If null, only this account's own IAM permissions govern access. | `null` | no |
| recovery_window_in_days | Days a deleted secret is recoverable before AWS permanently erases it (7-30), during which its name stays reserved and cannot be reused. Set 0 to delete immediately with no recovery window — only appropriate for a genuinely disposable secret (test/dev), since it forfeits the ability to undo an accidental deletion. If null, AWS's own default (30) applies. | `null` | no |
| secret_value | The secret's value, as a plain string persisted in Terraform state. Mutually exclusive with secret_value_wo. For a value that should never be written to state at all, use secret_value_wo instead — see the Design section. If both are null, the secret is created with no initial version (a valid state, e.g. when a rotation Lambda populates it after creation). | `null` | no |
| secret_value_wo | The secret's value, using Terraform's write-only attribute support — never persisted to state, only sent to AWS once per apply. Requires secret_value_wo_version, bumped by the caller to signal a new value (Terraform cannot diff a write-only value itself, since it never keeps a copy to compare against). Mutually exclusive with secret_value. Needs a Terraform version with write-only attribute support (1.11+). | `null` | no |
| secret_value_wo_version | Version marker for secret_value_wo — increment it any time secret_value_wo's actual value changes, since Terraform otherwise has no way to detect the change. Required together with secret_value_wo; unused otherwise. | `null` | no |
| tags | A map of tags to assign to the secret. | `null` | no |

## Outputs

| Name | Description |
|---|---|
| id | The ID of the secret. |
| arn | The ARN of the secret. |
| name | The name of the secret. Feed this into a consumer that reads the secret at runtime by name rather than ARN. |

## License

MIT — see [LICENSE.md](LICENSE.md).
