setenforce 0
podman build -t pgsql15 .
podman images
podman login docker.io
podman push localhost/pgsql15 docker.io/kostikpl/ol9:pgsql15
