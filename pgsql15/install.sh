podman build -t pgpro .
podman run --name pgpro --ip 10.88.0.2 --hostname pgpro.local -dt -p 5432:5432 -v /_data:/_data localhost/pgpro
podman push localhost\pgpro docker.io/kostikpl/rhel8:rhel8:pgpro-11.12.1_rhel-ubi-8.4
podman exec -ti -u root psql -f /_data/pg_backup/work.out postgers

podman run --name pgpro --ip 10.88.0.2 --hostname pgpro.local -dt -p 5432:5432 -v /_data:/_data docker.io/kostikpl/rhel8:rhel8:pgpro-11.12.1_rhel-ubi-8.4
