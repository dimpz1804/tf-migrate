terraform {
  required_providers {
    tfe = {
      version = "~> 0.55.0"
    }
    tfmigrate = {
      source  = "hashicorp/tfmigrate"
      version = "~> 1.2.0"
    }
  }
}

provider "tfmigrate" {
  hostname          = var.tfe_hostname
  allow_commit_push = var.allow_commit_push
  create_pr         = var.create_pr
}

provider "tfe" {
  hostname     = var.tfe_hostname
  organization = var.organization_name
}

locals {
  list_of_new_projects = toset(
    [for key, value in var.migration_directories : value.project_name]
  )
  list_of_working_directories = tolist(
    [for key, value in var.migration_directories : value.working_directory]
  )
  vcs_pr_body = <<-EOT
This PR is created by TFMigrate CLI to migrate the Workspaces from the repository 
${var.github_identifier} to the ${var.tfe_hostname}.

Important Post-Merge Step:

The migration branch used for this pull request may be deleted after the merge if it was created by the CLI. 
After merging this pull request, please update the branch reference in your Terraform workspace settings:

1. Go to your workspace in Terraform Cloud/Enterprise.

2. Navigate to Settings and then Version Control.

3. Update the VCS branch to point back to your original feature branch.

More info: https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings/vcs#vcs-branch
EOT

  cli_pr_body = <<-EOT
This PR is created by TFMigrate CLI to migrate the Workspaces from the repository 
${var.github_identifier} to the ${var.tfe_hostname}.
EOT
}

resource "tfe_project" "list_of_new_projects" {
  for_each    = local.list_of_new_projects
  name        = each.key
  description = "Created by Terrafrom Migrate from the Github Repository: ${var.github_identifier}"
}

module "workspace_and_variables" {
  depends_on = [tfe_project.list_of_new_projects]
  source     = "./workspace_variables_module"

  for_each = var.migration_directories

  organization_id = var.organization_name
  identifier      = var.github_identifier

  working_directory    = each.value.working_directory
  workspace_map        = each.value.workspace_map
  project_name         = each.value.project_name
  branch               = var.git_source_branch
  git_migration_branch = var.git_migration_branch
  remote_name          = var.git_remote
  backend_file_name    = each.value.backend_file_name
  tags                 = each.value.tags
  tf_version           = var.tf_version
  vcs_oauth_token_id   = var.vcs_oauth_token_id
}

resource "tfmigrate_git_commit_push" "create_commit" {
  depends_on     = [module.workspace_and_variables]
  count          = length(var.git_migration_branch) > 1 ? 1 : 0
  directory_path = local.list_of_working_directories[0]
  commit_message = var.git_commit_message
  branch_name    = var.git_migration_branch
  remote_name    = var.git_remote
}

resource "tfmigrate_git_pr" "migration_pr" {
  depends_on      = [tfmigrate_git_commit_push.create_commit]
  count           = length(var.github_identifier) > 1 && length(var.git_migration_branch) > 1 ? 1 : 0
  repo_identifier = var.github_identifier
  pr_title        = "HCP Migration of Workspaces in ${var.github_identifier} repository"
  pr_body = var.vcs_oauth_token_id != "" ? local.vcs_pr_body : local.cli_pr_body
  source_branch   = var.git_migration_branch
  destin_branch   = var.git_source_branch
}