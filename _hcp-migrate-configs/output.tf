output "workspace_ids" {
  value = module.workspace_and_variables
}

output "workspace_urls" {
  value = module.workspace_and_variables
}

output "list_of_new_project_ids" {
  value = values(tfe_project.list_of_new_projects).*.id
}

output "list_of_new_project_names" {
  value = values(tfe_project.list_of_new_projects).*.name
}

output "count_dir_skipped" {
  value = length(var.skipped_tf_dirs)
}

output "count_variables_migrated" {
  value = module.workspace_and_variables
}

output "migration_pr_link" {
  value = tfmigrate_git_pr.migration_pr.*.pull_request_url
}
