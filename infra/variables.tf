variable "yourname" {
  description = "Your name, lowercase, no spaces."
  type        = string
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "tags" {
  type = map(string)
  default = {
    project    = "container-pipeline"
    managed_by = "terraform"
  }
}
