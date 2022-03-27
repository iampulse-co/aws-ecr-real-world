This repo contains files related to the Calm Cloud Security ECR2: Practice video. 

[The video and article are here](https://iampulse.com/videos)

There are several files here:

* main.tf
  
  * Terraform to build our example ECR with IAM policy and outputs

* Dockerfile

  * Flat text file docker will read to build our container image

* docker_start.sh
  
  * Bash entrypoint file docker will embed in our container image, and which we'll use to receive variables and run within our container

* commands.sh

  * All commands used in the ECR practice video

