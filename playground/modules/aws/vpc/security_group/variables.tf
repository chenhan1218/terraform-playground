variable "dev_name" {
  description = "dev security group name"
  type        = string
  default     = "dev"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc_id" {
  description = "vpc_id"
  type        = string
  default     = null
}
