variable "name" {
  default     = null
  description = "Name of the secret. If null, a unique name is generated."
}

variable "description" {
  default     = null
  description = "A description of the secret."
}

variable "kms_key_id" {
  default     = null
  description = "ARN or ID of a KMS key to encrypt the secret with. If null, AWS's own managed key ('aws/secretsmanager') is used."
}

variable "policy" {
  default     = null
  description = "IAM resource policy document (JSON) controlling access to the secret, for cross-account access or an explicit deny. If null, only this account's own IAM permissions govern access."
}

variable "recovery_window_in_days" {
  default     = null
  description = "Days a deleted secret is recoverable before AWS permanently erases it (7-30), during which its name stays reserved and cannot be reused. Set 0 to delete immediately with no recovery window — only appropriate for a genuinely disposable secret (test/dev), since it forfeits the ability to undo an accidental deletion. If null, AWS's own default (30) applies."
}

variable "secret_value" {
  default     = null
  description = "The secret's value, as a plain string persisted in Terraform state. Mutually exclusive with secret_value_wo. For a value that should never be written to state at all, use secret_value_wo instead — see the Design section. If both are null, the secret is created with no initial version (a valid state, e.g. when a rotation Lambda populates it after creation)."
  sensitive   = true

  validation {
    condition     = var.secret_value == null || var.secret_value_wo == null
    error_message = "secret_value and secret_value_wo are mutually exclusive — set at most one."
  }
}

variable "secret_value_wo" {
  default     = null
  description = "The secret's value, using Terraform's write-only attribute support — never persisted to state, only sent to AWS once per apply. Requires secret_value_wo_version, bumped by the caller to signal a new value (Terraform cannot diff a write-only value itself, since it never keeps a copy to compare against). Mutually exclusive with secret_value. Needs a Terraform version with write-only attribute support (1.11+)."
  sensitive   = true

  validation {
    condition     = (var.secret_value_wo != null) == (var.secret_value_wo_version != null)
    error_message = "secret_value_wo and secret_value_wo_version are required together — Terraform needs the version bumped to know secret_value_wo actually changed."
  }
}

variable "secret_value_wo_version" {
  default     = null
  description = "Version marker for secret_value_wo — increment it any time secret_value_wo's actual value changes, since Terraform otherwise has no way to detect the change. Required together with secret_value_wo; unused otherwise."
}

variable "tags" {
  default     = null
  description = "A map of tags to assign to the secret."
}
