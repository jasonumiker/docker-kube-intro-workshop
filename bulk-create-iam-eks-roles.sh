#!/bin/bash
# Script to bulk create IAM Roles for EKS
# By Jason Umiker jason.umiker@gmail.com

set -e

NumberOfRoles=20

# Setting up the array
for (( c=1; c<=$NumberOfRoles; c++ ))
do
   Roles[c-1]="eks-user"$c
done

# The create_user function - we'll call this each time to create the user
create_role() {
  role=${1}
  aws iam create-role --role-name ${role} --assume-role-policy-document file://trust-policy-document.json
}

# The loop where we iterate through the job
for (( c=1; c<=NumberOfRoles; c++ ))
do
  # Create the User
  create_role ${Roles[$c-1]}
done