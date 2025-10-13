terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.0.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.28"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_types   = ["t3.medium"]
    }
  }

  manage_aws_auth = true
}

output "kubeconfig" {
  value = module.eks.kubeconfig
  sensitive = true
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
