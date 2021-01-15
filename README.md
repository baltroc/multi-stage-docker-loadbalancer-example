# multi-stage build docker and load balancer example

## Usage

This is an example for ubuntu servers.

If you want to try it you need to edit the hosts file and add your servers. web servers IPs in ubuntuGroup and your load balancer IP in main.In Caddyfile put your load balancer IP on top and the web servers IPs after the "to"

web servers playbook : ansible-playbook --private-key sshkey -i hosts server.yml

load balancer playbook : ansible-playbook --private-key sshkey -i hosts caddy.yml

web servers are setup to listen on port 8080. load balancer listen on port 8081 in this example.

## Dockerfile

#### Golang compilation

We use some compiler parameters to reduce de size of the binary.
  - CGO_ENABLED=0 We disable cgo because app.go doesn't use any C functions.
  - GGOOS=linux and GOARCH=amd64 We know our operating system and system architecture, we can compile only for them.
  - -ldflags="-w -s" We remove debugging informations and symbols table.

#### image with Busybox

We use the busybox image instead of Alpine beacause it's smaller and enough for this example. Around 13M with Alpine while we have around 4.8M with busybox.

We use the docker multi-stage build to reduce the number of layer.

#### server.yml

We register the ID of the old image then we use "force_source: yes" to recreate the image even if an image with the same name already exist to make sure any change is  added to the image and we recreate the container only if the image changed.

At the end we use docker_prune to delete all unused images, this can be an issue if you don't want to lose your unused images.

## load balancer

The load balancer is configured for Round Robin in the Caddyfile.
