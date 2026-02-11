run "network_module_plan" {
  command = plan

  assert {
    condition     = module.network != null
    error_message = "Network module failed to generate a plan."
  }
}