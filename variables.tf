variable "client_id" {
  description = "The Client ID for the Service Principal"
  type        = string
}

variable "client_secret" {
  description = "The Client Secret for the Service Principal"
  type        = string
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  default     = "polkadot-deployer"
  type        = string
}

variable "location" {
  description = "Azure location"
  type        = string
}

variable "node_count" {
  description = "Size of Kubernetes cluster"
  default     = 2
  type        = number
}

variable "machine_type" {
  description = "Type of virtual machines used for the cluster"
  default     = "Standard_D2s_v3"
  type        = string
}

variable "k8s_version" {
  description = "Kubernetes version to use for the AKS cluster"
  default     = "1.15.10"
  type        = string
}
