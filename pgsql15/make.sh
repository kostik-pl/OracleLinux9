#setenforce 0
podman build -t pgsql15 .
podman images
podman run --name pgsql15--ip 10.88.0.2 --hostname pgslq15.local -dt -p 5432:5432 -v /_data:/_data localhost/pgsql15
podman login docker.io
podman push localhost/pgsql15 docker.io/kostikpl/ol9:pgsql15
podman run --name pgsql15 --ip 10.88.0.2 --hostname pgslq15.local -dt -p 5432:5432 -v /_data:/_data docker.io/kostikpl/ol9:pgsql15
