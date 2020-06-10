#!/bin/bash
# Purpose: Add additional group to an existing EKS Cluster
# https://aws.amazon.com/premiumsupport/knowledge-center/eks-multiple-node-groups-eksctl/
# https://eksctl.io/usage/managing-nodegroups/

CLUSTER_NAME="cloudgeeks-ca-eks"

REGION="us-east-1"

VERSION="1.15"

KEY_NAME="cloudgeeks-ca-eks"

#Create a worker node group with custom parameters

#1. Define the parameters for the new worker node group in a configuration file. See the following example:

cat << EOF > additional-nodes-config
kind: ClusterConfig
apiVersion: eksctl.io/v1alpha5
metadata:
    name: $CLUSTER_NAME
    region: $REGION
nodeGroups:
  - name: ng1-Workers
    labels: { role: workers }
    availabilityZones: ["us-east-1a", "us-east-1b"]
    instanceType: t3a.medium
    desiredCapacity: 3
    volumeSize: 32
    VolumeType: gp2
    iam:
      instanceProfileARN: "arn:aws:iam::111139436029:instance-profile/eksctl-cloudgeeks-ca-eks-nodegroup-worker-NodeInstanceProfile-18NRW3RWYBGLA" #Attaching IAM role
      instanceRoleARN: "arn:aws:iam::111139436029:role/eksctl-cloudgeeks-ca-eks-nodegrou-NodeInstanceRole-1ULB8Y0ZCPBTD"
    privateNetworking: true
    securityGroups:
      withShared: true
      withLocal: true
      attachIDs: ['sg-04173abd92850c64c', 'sg-045a81aae6d72c611']
    ssh:
      publicKeyName: $KEY_NAME
    kubeletExtraConfig:
        kubeReserved:
            cpu: "300m"
            memory: "300Mi"
            ephemeral-storage: "1Gi"
        kubeReservedCgroup: "/kube-reserved"
        systemReserved:
            cpu: "300m"
            memory: "300Mi"
            ephemeral-storage: "1Gi"
    tags:
      'environment': 'development'
EOF

eksctl create nodegroup --config-file=additional-nodes-config

# eksctl get nodegroups --cluster yourClusterName
# eksctl get nodegroups --cluster cloudgeeks-ca-eks

# END
