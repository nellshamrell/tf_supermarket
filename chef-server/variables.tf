variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "us-east-1"
}
variable "instance_type" {}
variable "ami" {}
variable "subnet_id" {}
variable "vpc_security_group_ids" {}
variable "private_ssh_key_path" {}
variable "key_name" {}
variable "chef-server-user" {}
variable "chef-server-user-full-name" {}
variable "chef-server-user-email" {}
variable "chef-server-user-password" {}
variable "chef-server-org-name" {}
variable "chef-server-org-full-name" {}
