mock_provider "aws" {
}

run "rejects_both_secret_value_and_secret_value_wo" {
  command = plan

  variables {
    secret_value            = "plain-secret-value"
    secret_value_wo         = "write-only-secret-value"
    secret_value_wo_version = 1
  }

  expect_failures = [var.secret_value]
}

run "rejects_secret_value_wo_without_version" {
  command = plan

  variables {
    secret_value_wo = "write-only-secret-value"
  }

  expect_failures = [var.secret_value_wo]
}

run "rejects_version_without_secret_value_wo" {
  command = plan

  variables {
    secret_value_wo_version = 1
  }

  expect_failures = [var.secret_value_wo]
}

run "no_value_creates_no_version" {
  command = plan

  assert {
    condition     = length(aws_secretsmanager_secret_version.resource) == 0
    error_message = "No secret_value or secret_value_wo given should create no secret version."
  }
}

run "secret_value_creates_one_version" {
  command = apply

  variables {
    secret_value = "plain-secret-value"
  }

  assert {
    condition     = length(aws_secretsmanager_secret_version.resource) == 1
    error_message = "secret_value given should create exactly one secret version."
  }

  assert {
    condition     = aws_secretsmanager_secret_version.resource[0].secret_string == "plain-secret-value"
    error_message = "secret_value should pass through unchanged as secret_string."
  }
}

run "secret_value_wo_creates_one_version" {
  command = apply

  variables {
    secret_value_wo         = "write-only-secret-value"
    secret_value_wo_version = 1
  }

  assert {
    condition     = length(aws_secretsmanager_secret_version.resource) == 1
    error_message = "secret_value_wo given should create exactly one secret version."
  }
}

run "recovery_window_in_days_passes_through" {
  command = plan

  variables {
    recovery_window_in_days = 0
  }

  assert {
    condition     = aws_secretsmanager_secret.resource.recovery_window_in_days == 0
    error_message = "recovery_window_in_days should pass through unchanged, including the explicit 0 (immediate delete) case."
  }
}

run "kms_key_id_passes_through" {
  command = plan

  variables {
    kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/abcd1234-ab12-cd34-ef56-abcdef123456"
  }

  assert {
    condition     = aws_secretsmanager_secret.resource.kms_key_id == "arn:aws:kms:us-east-1:123456789012:key/abcd1234-ab12-cd34-ef56-abcdef123456"
    error_message = "kms_key_id should pass through unchanged."
  }
}

run "readme_default_example" {
  command = plan

  variables {
    description  = "Database password for the app service."
    secret_value = "plain-secret-value"
  }
}

run "readme_write_only_example" {
  command = plan

  variables {
    description             = "Database password for the app service."
    kms_key_id              = "arn:aws:kms:us-east-1:123456789012:key/abcd1234-ab12-cd34-ef56-abcdef123456"
    secret_value_wo         = "write-only-secret-value"
    secret_value_wo_version = 1
  }
}
