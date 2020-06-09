provider "aws" {
  region = "us-west-2"
}


module "vpc" {
  source = "../../modules/vpc"
  vpc-location                        = "Oregon"
  namespace                           = "cloudgeeks.ca"
  name                                = "vpc"
  stage                               = "prod"
  map_public_ip_on_launch             = "false"
  total-nat-gateway-required          = "1"
  create_database_subnet_group        = "false"
  vpc-cidr                            = "10.20.0.0/16"
  vpc-public-subnet-cidr              = ["10.20.1.0/24","10.20.2.0/24"]
  vpc-private-subnet-cidr             = ["10.20.4.0/24","10.20.5.0/24"]
  vpc-database_subnets-cidr           = ["10.20.7.0/24", "10.20.8.0/24"]
  cluster-name                        = "cloudgeeks.ca-prod-eks-cluster"

}

module "eks_workers" {
  source                             = "../../modules/eks-cluster-workers"
  namespace                          = "cloudgeeks.ca"
  stage                              = "prod"
  name                               = "eks"
  instance_type                      = "m5.large"
  vpc_id                             = module.vpc.vpc-id
  subnet_ids                         = module.vpc.private-subnet-ids
  associate_public_ip_address        = "false"
  health_check_type                  = "EC2"
  min_size                           = 2
  max_size                           = 3
  wait_for_capacity_timeout          = "10m"
  # Makesure to check the Latest EKS AMI according to AWS Region
  image_id                           = "ami-07be7092831897fd6"
  cluster_name                       = "cloudgeeks.ca-prod-eks-cluster"
  key_name                           = "vault"
  cluster_endpoint                   = module.eks_cluster.eks_cluster_endpoint
  cluster_certificate_authority_data = module.eks_cluster.eks_cluster_certificate_authority_data
  cluster_security_group_id          = module.eks_cluster.security_group_id


  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled           = true
  cpu_utilization_high_threshold_percent = 80
  cpu_utilization_low_threshold_percent  = 50
}

module "eks_cluster" {
  source                       = "../../modules/eks-cluster-master"
  namespace                    = "cloudgeeks.ca"
  stage                        = "prod"
  name                         = "eks"
  region                       = "us-west-2"
  cluster_name                 = "cloudgeeks.ca-prod-eks-cluster"
  vpc_id                       = module.vpc.vpc-id
  subnet_ids                   = module.vpc.public-subnet-ids
  kubernetes_version           = "1.14"
  kubeconfig_path              = "~/.kube/config"
  workers_role_arns            = [module.eks_workers.workers_role_arn]
  workers_security_group_ids   = [module.eks_workers.security_group_id]

  # "This configmap-auth.yaml is not exist, it will be automatically created & updated via scripts"
  configmap_auth_file          = "../../modules/eks-cluster-master/configmap-auth.yaml"
  oidc_provider_enabled        = true
  local_exec_interpreter       = "/bin/bash"



}
