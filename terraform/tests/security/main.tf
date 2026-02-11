terraform {
  required_version = ">= 1.6.0"
}

module "security" {
  source = "../../modules/security"

  name_prefix   = "ci-test"
  allowed_ports = [22, 80, 443]
}