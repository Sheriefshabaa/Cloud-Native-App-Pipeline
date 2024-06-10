#!/bin/bash

# Record start time
start_time=$(date +%s)

# Note: Run this script in the project directory

# 0. Connect to your AWS Account
read -p "Enter AWS Access Key ID: " aws_access_key_id
read -p "Enter AWS Secret Access Key: " aws_secret_access_key
read -p "Enter Default region name: " default_region_name
read -p "Enter Default output format [None]: " default_output_format

echo "MSG: Connecting to AWS User"
[ -n "$aws_access_key_id" ] && aws configure set aws_access_key_id "$aws_access_key_id"
[ -n "$aws_secret_access_key" ] && aws configure set aws_secret_access_key "$aws_secret_access_key"
[ -n "$default_region_name" ] && aws configure set default.region "$default_region_name"
[ -n "$default_output_format" ] && aws configure set default.output "$default_output_format"


# 1. Terraform
echo "MSG: Building Infrastructure..."
cd ./terraform 
chmod 400 ./project-key
if terraform apply -auto-approve
then
    echo "MSG: Terraform apply successfully."
else
    echo "ERROR: Terraform apply failed, exiting."
    exit 1
fi

# 2. Ansible
echo "MSG: configuring jenkins server..."
cd ../ansible 
export ANSIBLE_HOST_KEY_CHECKING=False  # Set ANSIBLE_HOST_KEY_CHECKING to False to avoid SSH host authenticity confirmation
if ansible-playbook jenkins.yml; then
    echo "MSG: Jenkins server configured."
else
    echo "ERROR: Ansible playbook failed, exiting."
    exit 1
fi

# 3. Run Images script
echo "MSG: Building & Pushing Images into ECRs..."
cd ../app
chmod +x images-build-push.sh
if ./images-build-push.sh; then
    echo "MSG: Images built and pushed successfully."
else
    echo "ERROR: Image build/push failed, exiting."
    exit 1
fi

# 4. connect to eks
echo "MSG: Configuring eks..."
cd ../k8s
aws eks update-kubeconfig  --region eu-west-1 --name h-project-eks-cluster
if ./k8s.sh; then
    echo "MSG: EKS configured successfully."
else
    echo "ERROR: EKS configuration failed, exiting."
    exit 1
fi

# Print Jenkins server IP & Admin Password
cd ../ansible
echo "Jenkins Server IP:"
awk '/\[jenkins_server\]/{getline; print}' inventory

echo "Jenkins Server Password:"
cat initialAdminPassword


# Record end time & Calculate execution time
end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo "Execution time: $execution_time seconds"