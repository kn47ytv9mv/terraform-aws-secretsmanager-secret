resource "random_uuid" "resource" {}

resource "aws_secretsmanager_secret" "resource" {
  name                    = coalesce(var.name, random_uuid.resource.id)
  description             = var.description
  kms_key_id              = var.kms_key_id
  policy                  = var.policy
  recovery_window_in_days = var.recovery_window_in_days

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "resource" {
  count = var.secret_value != null || var.secret_value_wo != null ? 1 : 0

  secret_id                = aws_secretsmanager_secret.resource.id
  secret_string            = var.secret_value
  secret_string_wo         = var.secret_value_wo
  secret_string_wo_version = var.secret_value_wo_version
}

output "id" {
  description = "The ID of the secret."
  value       = aws_secretsmanager_secret.resource.id
}

output "name" {
  description = "The name of the secret. Feed this into a consumer that reads the secret at runtime by name rather than ARN."
  value       = aws_secretsmanager_secret.resource.name
}

output "arn" {
  description = "The ARN of the secret."
  value       = aws_secretsmanager_secret.resource.arn
}
