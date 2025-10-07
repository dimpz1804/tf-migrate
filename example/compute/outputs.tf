output "strings" {
  description = "The list of generated strings"
  value       = random_string.this[*].id
}