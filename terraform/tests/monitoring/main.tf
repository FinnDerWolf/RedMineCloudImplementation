terraform {
  required_version = ">= 1.6.0"
}

module "monitoring" {
  source = "../../modules/monitoring"

  name_prefix = "ci-test"
}