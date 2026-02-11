run "security_module_plan" {
  command = plan

  assert {
    condition     = module.security != null
    error_message = "Security module failed to generate a plan."
  }
}