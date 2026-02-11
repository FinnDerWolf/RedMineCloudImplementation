run "monitoring_module_plan" {
  command = plan

  assert {
    condition     = module.monitoring != null
    error_message = "Monitoring module failed to generate a plan."
  }
}