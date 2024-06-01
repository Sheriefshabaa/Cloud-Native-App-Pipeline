#!/bin/bash
# Note: Run this script in the project directory

# 0. Connect to your AWS Account
read -p "Enter AWS Access Key ID: " aws_access_key_id
read -p "Enter AWS Secret Access Key: " aws_secret_access_key
read -p "Enter Default region name: " default_region_name
read -p "Enter Default output format [None]: " default_output_format
echo "Connecting to AWS User"
aws configure set aws_access_key_id $aws_access_key_id
aws configure set aws_secret_access_key $aws_secret_access_key
aws configure set default.region $default_region_name
aws configure set default.output $default_output_format

# 1. Terraform
echo "Building Infrastructure..."
cd ./terraform 
terraform apply -auto-approve
chmod 400 ./project-key

# 2. Ansible
echo "configuring jenkins server..."
cd ../ansible 
ansible-playbook jenkins.yml 

# 3. Run Images script
echo "Building & Pushing Images into ECRs..."
cd ../app
chmod +x images-build-push.sh
./images-build-push.sh 

# 4. connect to eks
echo "configuring eks..."
cd ../k8s
aws eks update-kubeconfig  --region eu-west-1 --name h-project-eks-cluster