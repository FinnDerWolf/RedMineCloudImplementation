run "compute_module_plan" {
  command = plan

  assert {
    condition     = module.compute != null
    error_message = "Compute module failed to generate a plan."
  }
}