#!/bin/bash
# Purpose: alb ingress setup via helm3
# https://aws.amazon.com/premiumsupport/knowledge-center/eks-alb-ingress-controller-fargate/
# https://github.com/aws/eks-charts
# https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller

EKS_CLUSTER="cloudgeeks-eks-dev"
REGION="us-east-1"
AWS_ACCOUNT_ID="602401143452"
# https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
VPC="vpc-0727e79dd350a3dbc"

export EKS_CLUSTER
export REGION
export AWS_ACCOUNT_ID
export VPC


helm version --short

helm repo add eks https://aws.github.io/eks-charts

# To install the TargetGroupBinding custom resource definitions (CRDs), run the following command:
# kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"

# https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
# To install the Helm chart, run the following command:

helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=eksdemo1 \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=vpc-0570fda59c5aaf192 \
   --set image.repository=${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/amazon/aws-load-balancer-controller
# END
