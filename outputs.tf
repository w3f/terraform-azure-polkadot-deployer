output "kubeconfig" {
  description = "kubectl config file contents for this AKS cluster"
  value       = azurerm_kubernetes_cluster.polkadot-aks.kube_config_raw
  sensitive   = true
}
