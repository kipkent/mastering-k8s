variable "github_org" {
  description = "GitHub organization"
  type        = string
  default     = "kipkent"
}

variable "github_repository" {
  description = "GitHub repository"
  type        = string
  default     = "flux-preview"
}

variable "github_token" {
  description = "GitHub token"
  sensitive   = true
  type        = string
}

variable "cluster_name" {
  description = "Cluster Name"
  type        = string
  default     = "preview"
}
