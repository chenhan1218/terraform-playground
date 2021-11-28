variable "name" {
  description = "instance name"
  type        = string
}

variable "instance_type" {
  description = "instance name"
  type        = string
  default     = "t3a.nano"
}


variable "image_id" {
  description = "image_id"
  type        = string
}
