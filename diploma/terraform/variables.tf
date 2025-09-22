variable "yandex_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
  sensitive   = true
}

variable "yandex_folder_id" {
  description = "Yandex Folder ID"
  type        = string
  sensitive   = true
}



variable "ssh_public_key" {
  description = "SSH public key for instances"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key file"
  type        = string
  default     = "~/.ssh/id_ed25519"
}



locals {
  ssh_public_key  = fileexists(var.ssh_public_key) ? file(var.ssh_public_key) : ""
  ssh_private_key = fileexists(var.ssh_private_key_path) ? file(var.ssh_private_key_path) : ""
}