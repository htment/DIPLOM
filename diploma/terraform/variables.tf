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
  default     = "~/.ssh/id_rsa.pub"
}