# Introduction to Docker and Kubernetes Hands-On Workshop

## Working Environment

### Cloud9
We have provisioned a Cloud9 instance and its browser-based IDE and terminal for each of you. This is a web interface to a Linux machine with Docker installed and ready to go. Being Linux, containers run right on these Cloud9 instances when you use the docker commands.

### Kubernetes
We have provisioned a kubernetes cluster based on AWS' EKS with a namespace for each of you and your Cloud9 is set up with the right config and credentials where it is ready to go. Using the `kubectl` command will 'just work' in the examples below. We'll be covering how to set up Kubernetes and how things work under-the-hood in another session soon.

## The Workshop

### Docker Basics
The first part of this workshop will focus on the fundamentals of Docker and how to use it locally within one machine.

1. Open the AWS console, choose the `Oregon` region on the upper right hand corner, choose the Cloud9 service and then click the button to lauch the IDE.
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
1. Pull down this repo onto your instance with `git clone https://github.com/jasonumiker/docker-kube-intro-workshop.git`
1. Type `cd docker-kube-intro-workshop` to change into that project.
1. Type `cat Dockerfile` to see our simple `Dockerfile` - this is just adding the local `index.html` to the container image overwriting the default.
1. Type `docker build -t nginx:1.0 .` to build nginx from our Dockerfile
1. Type `docker history nginx:1.0`. to see all the steps and base containers that our nginx:1.0 is built on. Note that our change amounts to one new tiny layer on top.
1. Type `docker run -p 8080:80 --name nginx nginx:1.0` to run our new container. Note that we didn't specify the `-d` to make it a daemon which means it holds control of our terminal and outputs the containers logs to there which can be handy in debugging.
1. Open another Terminal tab (Window -> New Terminal)
1. Type `curl http://localhost:8080` in the other tab a few times and see our new content.
1. Go back to the first tab and see the log lines sent right out to STDOUT.
1. At this point we could push it to Docker Hub or a private Registry like AWS' ECR for others to pull and run. We won't worry about that yet though.
1. Type Ctrl-C to exit the log output. Note that the container has been stopped but is still there by running a `docker ps`.
1. Type `sudo docker inspect nginx` to see lots of info about our stopped container.
1. Type `docker rm nginx` to delete our container.
1. Finally we'll try mouting some files from the host into the container rather than embedding them in the image. Run `docker run -d -p 8080:80 -v /home/ec2-user/environment/docker-kube-intro-workshop/index.html:/usr/share/nginx/html/index.html:ro --name nginx nginx:latest`
1. Do a `curl http://localhost:8080`. Note that even though this is the upstream nginx image from Docker Hub our content is there.
1. Edit the index.html file and add some more things.
1. Do another `curl http://localhost:8080` and note the immediate changes.
1. Run `docker stop nginx` and `docker rm nginx` to stop and remove our last container.

### Kubernetes Basics
This part of the workshop will focus on how to deploy and machine our containers on a pool of machines managed by Kuberenetes.

1. Type `kubectl version` to confirm that both the client and server are there and working.
1. Type `kubectl create deployment nginx --image=nginx` to create a single-Pod deployment of nginx.
1. Type `kubectl describe deployments` to see the details of our new deployment.
1. Type `kubectl describe pods` to see the pod that our deployment has created for us. Note that there is no port exposed for this contianer.
1. Type `kubectl describe replicasets` to see there is a replicaset too.
    1. A `Deployment` creates/manages `ReplicaSet(s)` which, in turn, creates the required `Pod(s)`.
1. Type `kubectl scale --replicas=3 deployment/nginx` to launch two more nginx Pods taking us to three.
1. Type `kubectl get deployments` and `kubectl get pods -o wide` to see our change has taken effect (that there are three pods running). Also note the Pod IPs (copy/paste them to notepad or something).
1. Type `kubectl run my-shell --rm -i --tty --image ubuntu -- bash` to connect interactively into `bash` on a new ubuntu pod.
1. Type `apt update; apt install curl -y` then `curl http://<an IP from describe pods>` and watch it load the default nginx page on our nginx pod.
    1. By default all pods in the cluster can reach all other pods in the cluster directly by IP. You can restrict this with `NetworkPolicies` which is Kubernetes' firewall.
1. Type `exit` and, because we did a --rm in the command above, it'll delete the deployment and pod once we disconnect from our interactive session.
1. Type `kubectl expose deployment nginx --port=80 --target-port=80 --name nginx --type=LoadBalancer` to create a service backed by an AWS Elastic Load Balancer that not only balances the load between all the Pods but exposes it to the Internet.
    1. It will take a minute to create the ELB. You can watch the progress of it being created in the AWS EC2 Console under `Load Balancers` on the left-hand side.
1. Type `kubectl get services` and copy the `EXTERNAL-IP` address. Open a web browser tab and go to `http://<that address>` and see it load. Note that it will take a minute or so for the ELB to be provisioned before this will work. Refresh this a few times to generate some access logs.
1. Type `kubectl logs -lapp=nginx` to get the aggregated logs of all the nginx Pods to see the details of our recent requests.
1. Type `kubectl get service/nginx deployment/nginx --export=true -o yaml > nginx.yml` to back up our work.
    1. Edit the file and have a look (double-click on it in Cloud9 in the pane on the left to open it in that IDE or use nano/vim in the Terminal). We could have written our requirements for what we need Kubernetes to do into YAML files like this in the first place instead of using these kubectl commands - and often you would do that and put it in a CI/CD pipeline etc. Note that you can put the definitions for multiple types of resources (in this example both a service and a deployment) in one YAML file.
1. Type `kubectl delete service/nginx deployment/nginx` to clean up what we've done.
1. Type `kubectl apply -f nginx.yml` to put it back again. See how easy it is to export and reapply the YAML?
1. In the Docker example we mounted a volume outside the container. You can do the same thing in Kubernetes at scale with a PersistentVolume (using an EBS volume in AWS) and a StatefulSet. Go through the example at https://eksworkshop.com/statefulset/ to see how you can run a stateful application like MySQL on the cluster.