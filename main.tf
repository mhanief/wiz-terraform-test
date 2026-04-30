terraform {
  required_version = ">= 1.0"
}

# Dummy resource (so Terraform has something to process)
resource "null_resource" "example" {
  provisioner "local-exec" {
    command = "echo insecure"
  }
}

# Hardcoded secret (Wiz should flag this)
locals {
  password = "SuperSecret123!"
}
