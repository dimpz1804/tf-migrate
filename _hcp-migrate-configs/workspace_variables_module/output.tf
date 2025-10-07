output "workspaces_ids" {
  value = [
    for k, v in tfe_workspace.workspaces : v.id
  ]
}

output "workspaces_url" {
  value = [
    for k, v in tfe_workspace.workspaces: v.html_url
  ]
}

output "count_variables_migrated" {
  value = length(tfe_variable.variables)
}