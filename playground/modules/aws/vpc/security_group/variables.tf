variable "dev_name" {
  description = "dev security group name"
  type        = string
  # TODO: remove default and refactor
  default = "dev-ssh"
}

variable "tags" {
  type    = map(string)
  default = {}
}
