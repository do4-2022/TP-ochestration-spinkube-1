variable "name" {
  description = "The name of the Helm release"
  type        = string
}

variable "service_account_name" {
  description = "The name of the service account to use"
  type        = string
}

variable "path" {
  description = "The path to the kustomization files"
  type        = string
}