Dockerized Microweber CMS
=========================


The difference from the [official](https://github.com/microweber/docker) docker image:
- Apache is running on Alpine. In the original image Debian is used.
- Solved potential conflict of config/userfiles folders.
They are tracked in the repo and at the same time are volumes
that can be modified by user.


Docker compose example:
```
version: '3.3'
services:
    microweber:
        image: karser/microweber:1.1.5
        volumes:
            - ./config:/var/www/microweber/config
            - ./userfiles:/var/www/microweber/userfiles
        environment:
            - DB_USER=microweber
            - DB_PASS=microweber
            - DB_NAME=microweber
            - DB_ENGINE=pgsql
            - DB_HOST=db
            - DB_PORT=5432
            - DB_PREFIX=
            - MW_EMAIL=your@email.com
            - MW_USER=admin
            - MW_PASSWORD=******
            - MW_TEMPLATE=liteness
        depends_on:
            - db
        restart: on-failure:10
        ports:
            - 8080:80
    db:
        image: postgres:9.6-alpine
        volumes:
            - ./db_data:/var/lib/postgresql/data
        environment:
            - POSTGRES_USER=microweber
            - POSTGRES_PASSWORD=microweber
            - POSTGRES_DB=microweber
        restart: on-failure:10
```


### After update:

The `userfiles` directory is bind-mounted so it needs to be updated manually
```
docker exec -it <container_name> bash
cp -r /var/www/microweber-defaults/userfiles /var/www/microweber
chown -R apache:apache /var/www/microweber/userfiles
```


Manual build
```
cd microweber/
export MICROWEBER_VERSION=1.1.11
 
docker build --build-arg MICROWEBER_VERSION=${MICROWEBER_VERSION}.x-dev \
    --tag karser/microweber:$MICROWEBER_VERSION \
    --tag karser/microweber:latest .

docker push karser/microweber:$MICROWEBER_VERSION
docker push karser/microweber:latest
```
