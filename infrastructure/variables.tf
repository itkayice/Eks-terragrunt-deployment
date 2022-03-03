variable "stack_name" {
  description = "Name of stack"
  type        = string
  default = "sample-go-app"
}

variable "cluster_name" {
  description = "Name of EKS cluster"
  type        = string
  default = "test-cluster"
}

variable "ecr_repo_name" {
  description = "Name of ECR repo"
  type        = string
  default = "go-app-repo"
}

