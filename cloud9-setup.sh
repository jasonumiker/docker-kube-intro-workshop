# Update awscli
sudo -H pip install -U awscli

# Install kubectl
curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/bin/linux/amd64/kubectl
chmod +x kubectl && sudo mv kubectl /usr/local/bin/
echo "source <(kubectl completion bash)" >> ~/.bashrc

# Install Heptio Authenticator
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/bin/linux/amd64/heptio-authenticator-aws
chmod +x ./aws-iam-authenticator && sudo mv aws-iam-authenticator /usr/local/bin/

# Configure AWS CLI
availability_zone=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)
export AWS_DEFAULT_REGION=${availability_zone%?}

# Persist lab variables
echo "AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" >> ~/.bashrc
