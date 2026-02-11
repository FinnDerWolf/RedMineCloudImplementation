terraform {
  required_version = ">= 1.6.0"
}

module "compute" {
  source = "../../modules/compute"

  name_prefix    = "ci-test"
  instance_count = 1
}