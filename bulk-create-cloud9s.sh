#!/bin/bash
# Script to bulk create Cloud9 Instances
# By Jason Umiker jason.umiker@gmail.com
# Usage bulk-create-cloud9s.sh account# subnetID user-#-to-start-with

set -e

NumberOfInstances=20

# We need to get the account # and subnet ID as parameters
if [ "$1" == "" ]; then
    echo "Usage bulk-create-cloud9s.sh account# subnetID"
    exit 1  
fi
if [ "$2" == "" ]; then
    echo "Usage bulk-create-cloud9s.sh account# subnetID"  
    exit 1
fi

acct=$1
subnet=$2

# Setting up the array
if [ "$3" == "" ]; then
    for (( c=1; c<=$NumberOfInstances; c++ ))
    do
        Users[c-1]="user"$c
    done
fi
if [ "$3" != "" ]; then
    for (( c=$3; c<=$NumberOfInstances; c++ ))
    do
        Users[c-1]="user"$c
    done
fi

# The create_user function - we'll call this each time to create the user
create_instance() {
  user=${1}
  acct=${2}
  subnet=${3}
  aws cloud9 create-environment-ec2 --name $user --description "Intro to Docker and Kube" --instance-type t3.large --subnet-id $subnet --automatic-stop-time-minutes 60 --owner-arn arn:aws:iam::$acct:user/$user --region us-west-2
}

# The loop where we iterate through the job
if [ "$3" == "" ]; then
    for (( c=1; c<=NumberOfInstances; c++ ))
    do
    # Create the Instance
    create_instance ${Users[$c-1]} $acct $subnet
    done
fi
if [ "$3" != "" ]; then
    for (( c=$3; c<=NumberOfInstances; c++ ))
    do
    # Create the Instance
    create_instance ${Users[$c-1]} $acct $subnet
    done
fi