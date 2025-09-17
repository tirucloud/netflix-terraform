variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string

}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  

}

variable "key_name" {
  description = "Key pair name for the EC2 instance"
  type        = string

}
variable "security_group" {
  description = "Security group for the EC2 instance"
  type        = string
}

variable "region" {
  description = "AWS region for the resources"
  type        = string
}