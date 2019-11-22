# EMR general configurations
name = "spark-app"
region = "us-west-2"
subnet_id = "subnet-02b2731c07384f6d2"
vpc_id = "vpc-04a7f889ef6d67036"
key_name = "vault"
ingress_cidr_blocks = "0.0.0.0/0"
release_label = "emr-5.16.0"
applications = ["Spark"]

# Master node configurations
master_instance_type = "m3.xlarge"
master_ebs_size = "50"

# Slave nodes configurations
core_instance_type = "m3.xlarge"
core_instance_count = 1
core_ebs_size = "50"
