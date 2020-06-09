#!/bin/bash
#Purpose Kubernetes Automated DashBoard
#Maintaner: muhammad.asim@cloudgeeks.ca.com
#OS: Ubuntu-18/16/AmazonLinux/CentOS

CUSTER_NAME="cloudgeeks.ca-eks"

DIR="$PWD/Kubernetes-DashBoard"

if [[ ! -e $DIR ]]; then
    mkdir $DIR
elif [[ ! -d $DIR ]]; then
    echo "$DIR already exists but is not a directory" 1>&2
fi

# https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

# https://github.com/kubernetes/dashboard

echo -e "\nInstalling AWS IAM authenticator ---> (This allows us to administor our EKS Clustor, using our IAM Identity)\n"

# https://github.com/kubernetes-sigs/aws-iam-authenticator

echo -e "\nWe are using the AWS Version of IAM authenticator ---> https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html\n"

curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator

chmod +x ./aws-iam-authenticator

mkdir -p $HOME/bin && mv ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$HOME/bin:$PATH



#########################
### Kubernetes Dashboard
#########################
echo -e "\nInstalling the Kubernetes Dashboard\n"

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-rc7/aio/deploy/recommended.yaml
echo -e "\nInstalling Heapster and InfluxDB\n"


kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/rbac/heapster-rbac.yaml

echo -e "\nCreating an administrative account and cluster role binding\n"

cat << EOF  > $DIR/eks-admin-service-account.yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: eks-admin
  namespace: kube-system
EOF

cat << EOF > $DIR/eks-admin-cluster-role-binding.yaml

apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
 name: eks-admin
roleRef:
 apiGroup: rbac.authorization.k8s.io
 kind: ClusterRole
 name: cluster-admin
subjects:
- kind: ServiceAccount
  name: eks-admin
  namespace: kube-system
EOF

ls $DIR

kubectl apply -f $DIR/eks-admin-service-account.yaml
kubectl apply -f $DIR/eks-admin-cluster-role-binding.yaml


# Token & Access

yum install -y jq 2>&1  > /dev/null

apt-get install jq 2>&1  > /dev/null

aws-iam-authenticator -i $CUSTER_NAME token | jq -r .status.token

echo -e "\nAfter 10 seconds access your kubernetes dashboard\n"
echo -e "\nLog in URL\n"
echo -e "\nhttp://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/n"

for (( i=1; i<=10; i=i+1 ))
do
sleep 1
echo $i
done

kubectl proxy  &

#END
