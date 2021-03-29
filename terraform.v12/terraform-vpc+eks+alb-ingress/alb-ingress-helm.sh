#!/bin/bash
# Purpose: alb ingress setup via helm3
# https://aws.amazon.com/premiumsupport/knowledge-center/eks-alb-ingress-controller-fargate/
# https://github.com/aws/eks-charts
# https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller

EksCluster="cloudgeeksca-cluster-eks"
Region="us-east-1"
VpcId=`aws ec2 describe-vpcs --region us-east-1 --filters Name=tag:Name,Values=cloudgeeksca-cluster-eks --query "Vpcs[].VpcId" | grep -i vpc | cut -f1`

# Install the AWS Load Balancer Controller using Helm

helm version --short

helm repo add eks https://aws.github.io/eks-charts

# To install the TargetGroupBinding custom resource definitions (CRDs), run the following command:


kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"


# To install the Helm chart, run the following command:

helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName="${EksCluster}"











# END
