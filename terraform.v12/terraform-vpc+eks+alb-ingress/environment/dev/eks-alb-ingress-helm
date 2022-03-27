#!/bin/bash
# Purpose: alb ingress setup via helm3
# https://aws.amazon.com/premiumsupport/knowledge-center/eks-alb-ingress-controller-fargate/
# https://github.com/aws/eks-charts
# https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller

EKS_CLUSTER="cloudgeeks-eks-dev"
REGION="us-east-1"
AWS_ACCOUNT_ID="602401143452"
# https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html

helm version --short

helm repo add eks https://aws.github.io/eks-charts

# To install the TargetGroupBinding custom resource definitions (CRDs), run the following command:

helm repo update
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"


# To install the Helm chart, run the following command:

helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set serviceAccount.create=true --set region=${REGION} --set image.repository=${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/amazon/aws-load-balancer-controller --set clusterName=${EKS_CLUSTER} --set serviceAccount.create=true --set serviceAccount.name=aws-load-balancer-controller



# END
