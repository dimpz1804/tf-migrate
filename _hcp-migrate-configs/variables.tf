variable "organization_name" {
  description = "HCP Terraform / TFE organization name in which the workspaces will be migrated"
  default     = "dimpy-test"
}
variable "tfe_hostname" {
  description = "Terraform Enterprise hostname to create resources"
  default     = "app.terraform.io"
}
variable "tf_version" {
  description = "Terraform version to be used for migration"
  default     = "1.10.0"
}
variable "vcs_oauth_token_id" {
  description = "OAuth token ID for the VCS provider. This is used to create the VCS connection in TFE / HCP Terraform"
  default     = ""
}
variable "git_migration_branch" {
  description = "Branch to which the migration changes will be pushed"
  default     = ""
}
variable "git_remote" {
  description = "Name of the GitHub Remote Stream to which the changes will be pushed e.g Origin"
  default     = ""
}
variable "git_source_branch" {
  description = "Base branch to which the pull request will be opened"
  default     = ""
}
variable "github_identifier" {
  description = "GitHub repository identifier in the form of <ORG/REPO_NAME> "
  default     = ""
}
variable "git_commit_message" {
  description = "The commit message to be used for creating the git commit with migration changes"
  default     = "[skip ci] Migrating local Workspaces from tf-migrate to HCP Terraform"
}
variable "allow_commit_push" {
  description = "Allow commit push to the git repo"
  default     = false
}
variable "create_pr" {
  description = "Create a pull request for the changes"
  default     = false
}
variable "skipped_tf_dirs" {
  description = "List of directories that are skipped from migration"
  default     = ["s3"]
}
variable "migration_directories" {
  description =<<-EOT
    This contains the map with all the information required to create HCP Terraform / TFE workspaces.
    The key is indicative of the folder which contains the configs.
    The individual parameters are described below:

    backend_file_name - Contains the name of the tf-file that has the backend block
    current_backend - Indicates the current backend
    project_name - Name of Project under which the workspaces will be created in HCP terraform / TFE
    tags - Tags that get created when there are multiple terraform workspaces
    working_directory - The directory path where the configs are detected
    workspace_map - The mapping of the local workspace to the TFE / HCP Terraform workspace that is going to be created.
EOT
  default = {
    "example/compute" = {
      backend_file_name = "main.tf"
      current_backend   = "s3"
      project_name      = "example_compute"
      tags              = ["example_compute"]
      working_directory = "/Users/dimpychugh/tf-practice/tf-migrate/tf-migrate/example/compute"
      workspace_map = {
        default = {
          tfc_workspace_name = "example_compute_default"
          variables_map = {
            string_count = {
              description = "Number of strings to create"
              hcl         = false
              name        = "string_count"
              sensitive   = false
              source_type = "terraform"
              value       = 3
            }
            string_length = {
              description = "Length of each string"
              hcl         = false
              name        = "string_length"
              sensitive   = false
              source_type = "terraform"
              value       = 32
            }
          }
          workspace_mode = "cli"
        }
        testing = {
          tfc_workspace_name = "example_compute_testing"
          variables_map = {
            string_count = {
              description = "Number of strings to create"
              hcl         = false
              name        = "string_count"
              sensitive   = false
              source_type = "terraform"
              value       = 3
            }
            string_length = {
              description = "Length of each string"
              hcl         = false
              name        = "string_length"
              sensitive   = false
              source_type = "terraform"
              value       = 32
            }
          }
          workspace_mode = "cli"
        }
      }
    }
    "example/storage" = {
      backend_file_name = "main.tf"
      current_backend   = "s3"
      project_name      = "example_storage"
      tags              = ["example_storage"]
      working_directory = "/Users/dimpychugh/tf-practice/tf-migrate/tf-migrate/example/storage"
      workspace_map = {
        default = {
          tfc_workspace_name = "example_storage_default"
          variables_map = {
            string_count = {
              description = "Number of strings to create"
              hcl         = false
              name        = "string_count"
              sensitive   = false
              source_type = "terraform"
              value       = 3
            }
            string_length = {
              description = "Length of each string"
              hcl         = false
              name        = "string_length"
              sensitive   = false
              source_type = "terraform"
              value       = 32
            }
          }
          workspace_mode = "cli"
        }
      }
    }
  }
}
