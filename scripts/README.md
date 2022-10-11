# **XFace System DataBase**

## **Requirements**
docker and docker-compose
- Resources include sql file to create table when docker-compose run
## **Installation**
```
```
## **How To Run**
- Run a MariaDB with adminer ui.
```
docker-compose -f docker-compose-mariadb.yml up -d
```
- Run a MongoDB with mongo express ui.
```
docker-compose -f docker-compose-mongodb.yml up -d
```
- Run a Redis with redis commander ui.
```
docker-compose -f docker-compose-redis.yml up -d
```
- Get Mariadb container ip, port biding informations to mariadb_container_info.conf file.
```
./get_container_info.sh
```
- Create database user, grant privileges on xface_system database for services access.
```
./create_database_user.sh
```
- Create a super account in account table for xface_system.
```
./create_root_account.sh
```


