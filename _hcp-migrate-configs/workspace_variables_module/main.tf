data "tfe_project" "project" {
  name         = var.project_name
  organization = var.organization_id
}

resource "tfe_workspace" "workspaces" {
  for_each            = var.workspace_map
  name                = each.value.tfc_workspace_name
  queue_all_runs      = false
  project_id          = data.tfe_project.project.id
  assessments_enabled = false
  terraform_version   = var.tf_version
  tag_names           = var.tags
  source_name         = "Tf-Migrate"
  source_url          = "https://github.com/hashicorp/tf-migrate"  
  working_directory   = each.value.workspace_mode == "vcs" ? try(each.value.tfe_working_directory, null) : null
  dynamic "vcs_repo" {
    for_each = each.value.workspace_mode == "vcs" ? [1] : []
    content {
      identifier      = var.identifier
      branch          = var.git_migration_branch
      oauth_token_id  = var.vcs_oauth_token_id
      ingress_submodules = true      
    }
  }
}

resource "tfe_variable" "variables" {
  for_each = {
    for combination in flatten([
      for workspace_key, workspace in var.workspace_map : [
        for variable_name, variable in workspace.variables_map : {
          key          = variable.name
          value        = variable.value != null ? variable.hcl ? replace(jsonencode(variable.value), "/\"([^\"]+)\":/", "$1 = ") : tostring(variable.value) : ""
          category     = variable.source_type
          workspace_name = workspace.tfc_workspace_name
          workspace_id = tfe_workspace.workspaces[workspace_key].id
          description  = variable.description
          sensitive    = variable.sensitive
          hcl          = variable.hcl
        }
      ]
    ]) :
    "${combination.workspace_name}.${combination.key}" => combination
  }
  key          = each.value.key
  category     = each.value.category
  workspace_id = each.value.workspace_id
  description  = each.value.description
  sensitive    = each.value.sensitive
  hcl          = each.value.hcl
  value        = each.value.value
}

resource "tfmigrate_terraform_init" "terraform_init" {
  depends_on     = [tfe_workspace.workspaces]
  directory_path = var.working_directory
}

resource "tfmigrate_state_migration" "state-migration" {
  depends_on      = [tfmigrate_terraform_init.terraform_init]
  for_each        = var.workspace_map
  local_workspace = each.key
  tfc_workspace   = each.value.tfc_workspace_name
  directory_path  = var.working_directory
  org             = var.organization_id
}

locals {
  transformed_workspace_map = {
    for key, value in var.workspace_map : key => value.tfc_workspace_name
  }
}

resource "tfmigrate_update_backend" "update-backend" {
  depends_on        = [tfmigrate_state_migration.state-migration]
  org               = var.organization_id
  project           = data.tfe_project.project.name
  directory_path    = var.working_directory
  backend_file_name = var.backend_file_name
  workspace_map     = local.transformed_workspace_map
  tags              = var.tags
}
