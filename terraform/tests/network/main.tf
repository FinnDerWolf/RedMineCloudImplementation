terraform {
  required_version = ">= 1.6.0"
}

module "network" {
  source = "../../modules/network"

  name_prefix = "ci-test"
  cidr_block  = "10.10.0.0/24"
}