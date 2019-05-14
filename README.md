# Introduction to Docker and Kubernetes Hands-On Workshop

## Working Environment

### Cloud9
All of the local Docker commands will be run within a Cloud9 environment. Cloud9 is a combination of a dedicated Linux instance on EC2 and a nice browser-based front-end for it that includes both an Integrated Development Envornment (IDE) and a Shell to interact with it. The steps to set up this Cloud9 are in our EKS Workshop <https://eksworkshop.com/prerequisites/self_paced/workspace/#region-3>. The closest region it is available to us is Singapore so please create it there.

You can do the [Docker Basics](#docker-basics) steps from just a newly launched Cloud9 without worrying about IAM or the Kubernetes setup steps.

### Kubernetes
To do the [Kubernetes Basics](#kubernetes-basics) steps we'll need to set up an EKS cluster. The instructions to do that are in the <https://eksworkshop.com> guide under `Start the workshop ... on your own`. Please continue those instructions including the `Create an IAM role for your Workspace`, `Attach the IAM role to your Workspace`, `Install Kubernetes Tools`, `Update the IAM settings for your Workspace`, `Create an SSH key` and `Launch using eksctl`. Then stop and complete the [introductory steps in this guide](#kubernets-basics) before proceeding with that workshop.

## The Workshop

### Docker Basics
The first part of this workshop will focus on the fundamentals of Docker and how to use it locally within one machine.

1. Type `docker version` to confirm that both the client and server are there and working.
1. Type `docker pull nginx:latest` to pull down the latest nginx trusted image from Docker Hub.
1. Type `docker images` to verify that the image is now on your local machine's Docker cache. If we start it then it won't have to pull it down from Docker Hub first.
1. Type `docker run –d –p 8080:80 --name nginx nginx:latest` to instantiate the nginx image as a background daemon with port 8080 on the host forwarding through to port 80 within the container
1. Type `docker ps` to see that our nginx container is running.
1. Type `curl http://localhost:8080` to use the nginx container and verify it is working with its default `index.html`.
1. Type `docker logs nginx` to see the logs produced by nginx and the container from our loading a page from it.
1. Type `docker exec -it nginx /bin/bash` for an interactive shell into the container's filesystem and constraints
1. Type `cd /usr/share/nginx/html` and `cat index.html` to see the content the nginx is serving which is part of the container.
1. Type `exit` to exit our shell within the container.
1. Type `docker stop nginx` to stop the container.
1. Type `docker ps -a` to see that our container is still there but stopped. At this point it could be restarted with a `docker start nginx` if we wanted.
1. Type `docker rm nginx` to remove the container from our machine
1. Type `docker rmi nginx:latest` to remove the nginx image from our machine's local cache
1. Type `git clone https://github.com/jasonumiker/docker-kube-intro-workshop.git`.
1. Type `cd docker-kube-intro-workshop` to change into that project.
1. Type `docker build -t nginx:1.0 .` to build nginx from our Dockerfile
1. Type `docker history nginx:1.0`. to see all the steps and base containers that our nginx:1.0 is built on. Note that our change amounts to one new tiny layer on top.
1. Type `docker run -p 8080:80 --name nginx nginx:1.0` to run our new container. Note that we didn't specify the `-d` to make it a daemon which means it holds control of our terminal and outputs the containers logs to there which can be handy in debugging.
1. Type `curl http://localhost:8080` in another terminal tab a few times and see our new content as well as the log lines in our origional terminal. 
1. At this point we could push it to Docker Hub or a private Registry like AWS' ECR for others to pull and run. We won't worry about that yet and will cover it in the next Kubernetes session.
1. Type Ctrl-C to exit the log output. Note that the container is still running though if you do a `docker ps`.
1. Type `sudo docker inspect nginx` to see lots of info about our running container.
1. Type `docker stop nginx` to shut our container down.

### Kubernetes Basics
This part of the workshop will focus on how to deploy and machine our containers on a pool of machines managed by Kuberenetes.

Ensure you have completed the setup as described in (#Kubernetes) first.

1. Type `kubectl version` to confirm that both the client and server are there and working.
1. Type `kubectl create deployment nginx --image=nginx` to create a single-Pod deployment of nginx.
1. Type `kubectl describe deployments` to see the details of our new deployment.
1. Type `kubectl describe pods` to see the pod that our deployment has created for us. Note that there is no port exposed for this contianer.
1. Type `kubectl describe replicasets` to see there is a replicaset too.
    1. A `Deployment` creates/manages `ReplicaSet(s)` which, in turn, creates the required `Pod(s)`.
1. Type `kubectl scale --replicas=3 deployment/nginx` to launch two more nginx Pods taking us to three.
1. Type `kubectl describe deployments` and `kubectl describe pods` to see our change has taken effect (that there are three pods running).
1. Type `kubectl run my-shell --rm -i --tty --image ubuntu -- bash` to connect interactively into `bash` on a new ubuntu pod.
1. Type `apt update` then `apt install curl` then `curl http://<IP from describe pods>` and watch it load the default nginx page on our nginx pod.
    1. By default all pods in the cluster can reach all other pods in the cluster. You can restrict this with `NetworkPolicies`.
1. Type `exit` and, because we did a --rm in the command above, it'll delete the deployment and pod once we disconnect from our interactive session.
1. Type `kubectl expose deployment nginx --port=80 --target-port=80 --name nginx --type=LoadBalancer` to create a service backed by an AWS Elastic Load Balancer that not only balances the load between all the Pods but exposes it to the Internet.
    1. It will take a minute to create the ELB. You can watch the progress of it being created in the AWS EC2 Console under `Load Balancers` on the left-hand side.
1. Type `kubectl describe services` and copy the `LoadBalancer Ingress` address. Open a web browser tab and go to `http://<that address>` and see it load. Note that it will take a minute or so for the ELB to be provisioned before this will work. Refresh this a few times to generate some access logs.
1. Type `kubectl logs -lapp=nginx` to get the aggregated logs of all the nginx Pods to see the details of our recent requests.
1. Type `kubectl get service/nginx deployment/nginx --export=true -o yaml > nginx.yml` to back up our work.
    1. Edit the file and have a look (double-click on it in Cloud9 to open it in that IDE or use nano/vim in the Terminal). We could have written our requirements for what we need Kubernetes to do into YAML files like this in the first place instead of using these kubectl commands - and often you would do that and put it in a CI/CD pipeline etc. Note that you can put the definitions for multiple types of resources (in this example both a service and a deployment) in one YAML file.
1. Type `kubectl delete service/nginx deployment/nginx` to clean up what we've done.
1. Type `kubectl apply -f nginx.yml` to put it back again. See how easy it is to export and reapply the YAML?
1. Leave it running this time to see a bit about it in the Kubernetes Dashboard when continuing on with <https://eksworkshop.com>.
