# Setting up EKS and Cloud9s in Shared Account

We'll be creating the following in one shared account:
* An EKS cluster
* 20 IAM Users for attendees to sign in with
* 20 Cloud9 Instances
* 20 IAM Roles mapped to 20 Kubernetes Namespaces
    * One role per user assigned to to their Cloud9

To set up the environment:
1. Create an AWS Account and sign in with Admin privilenges
1. Create an EC2 role with Administrator privilges
1. Create an Amazon Linux 2 EC2 instance with that role in one of the default public subnets in Oregon (us-west-2)
    1. Choose to create a new SSH key and download that to SSH onto it
1. SSH to that instance
1. Run the following commands:
    1. `sudo yum install git -y`
    1. `git clone https://github.com/jasonumiker/docker-kube-intro-workshop.git`
    1. `git clone https://github.com/jasonumiker/bulk-create-iam-users.git`
    1. `cd docker-kube-intro-workshop`
    1. `chmod u+x eks-setup-script.sh bulk-create-iam-eks-roles.sh`
    1. `./eks-setup-script.sh`
    1. `eksctl create cluster --name=eks --nodes=3 --node-ami=auto --region=us-west-2 --node-type m5.large`
    1. `kubectl edit -n kube-system configmap/aws-auth`
        1. Find/Replace account number in aws-auth-addition.yml with yours and then copy/paste it under mapRoles in the editor
    1. `kubectl apply -f eks-user.yml`
    1. `cd ../bulk-create-iam-users.git`
    1. `chmod u+x *`
    1. `./bulk-create-iam-users.sh`
    1. `cd ../docker-kube-intro-workshop`
    1. `./bulk-create-cloud9s.sh <AWS Account #> <one of the EKS Public Subnet IDs>`
        1. If you get throttled note where it left off and rerun it with a 3rd parameter of the user # to start with. If it made it to 10 then put an 11 for the next user to create.
1. Assign the EC2 role with Admin privileges to each Cloud9 instance in the EC2 console
1. Sign in as each user and connect to each Cloud9 instance and:
    1. Close all the windows and open one big Terminal window
    1. Turn off AWS managed temporary credentials in settings (so it uses the full Admin IAM Role we assigned)
    1. Run the following command (the first time) - `aws eks update-kubeconfig --name eks --role-arn arn:aws:iam::111111111111:role/eks-userXX --region us-west-2`
        1. If you copy/paste this somewhere you can then just paste it in for the subsequent users incrementing the role # as requried.
    1. Change the `~/.kube/config` file to add the namespace to the context as per example-kubeconfig.txt
    1. Run the `eks-setup-script.sh` to install kubectl and the authenticator plugin.
    1. Run `kubectl` get all and see it worked
    1. Close and re-open a new Terminal window so when the attendee signs in it is all fresh