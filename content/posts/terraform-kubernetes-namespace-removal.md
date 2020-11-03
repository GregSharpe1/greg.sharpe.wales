---
title: "Terraform Kubernetes Namespace Removal"
date: 2020-11-03T18:18:27Z
tags: ['AWS', 'Terraform', 'Nginx-ingress', 'Kubernetes', 'Help', 'Tech', 'Infrastructure', 'Tutorial']
draft: false
---

# Introduction

I'm currently working with Terraform, Kubernetes (EKS) and [Nginx-ingress](https://github.com/kubernetes/ingress-nginx) inside AWS. One of the issue I was seeing is when destroying an environment, the Elastic Load Balancer that the nginx-ingress is setting up isn't removed because on destroy of the environment the EKS cluster is being torned down without the removal of the service responsible for creating the ELB.

## Solution

This is obviously one solution and there maybe (probably will be) a solution that best suits your requirements. The solution for me, was to make sure the Kubernetes namespaces are torn down before the EKS cluster, and as Terraform is controlling this, a `null_resource` was used to do that very thing.

```
// On delete of the eks cluster, remove all namespaces which should clean up resources potentially creating infrastructure
// outside of the Terraform state.
//   * Nginx-ingress creating ELB for example
resource null_resource k8s_ns_cleanup {
  triggers = {
    kubeconfig_filename = module.eks.kubeconfig_filename
  }

  provisioner local-exec {
    when        = destroy
    interpreter = ["/bin/bash", "-c"]

    command = <<EOT
    KUBE_SYSTEM=("kube-system" "default" "flux" "kube-node-lease" "kube-public")
    for ns in $(kubectl get ns --kubeconfig "${self.triggers.kubeconfig_filename}" -o jsonpath="{.items[*].metadata.name}");
    do
      if [[ "$${KUBE_SYSTEM[*]}" =~ $ns ]]; then
        continue
      else
        kubectl delete ns --kubeconfig "${self.triggers.kubeconfig_filename}" "$ns";
      fi
    done
    EOT
  }
}
```

The above will remove all of the resources outside of the `kube-system`, `default`, `kube-node-lease`, `kube-public` and `flux` (flux for us is the only namespace created within our Terraform configuration through the use of Helm provider and Kubernetes)
