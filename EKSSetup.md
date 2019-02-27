# Setting up EKS

1. Create an EC2 role with Administrator privilges
1. Create an EC2 instance with that role in one of the default public subnets
    1. Choose to create a new SSH key and download that to SSH onto it
1. SSH to that instance
1. Run the following commands:
    1. `eks-setup-script.sh`
    1. `eksctl create cluster --name=eksworkshop-eksctl --nodes=3 --node-ami=auto --region=ap-southeast-1 --node-type m4.large`
    1. `git clone https://github.com/jasonumiker/bulk-create-iam-users.git`
    1. `chmod u+x bulk-create-iam-users/bulk-create-iam-users.sh`
    1. `kubectl edit -n kube-system configmap/aws-auth`
        1. Find/Replace account number in aws-auth-addition.yml with yours and then copy/paste it under mapRoles here
    1. `kubectl apply -f eks-user.yml`
    1. Edit the trust-policy-document.json to include the correct account number
    1. `./bulk-create-iam-eks-roles.sh`
