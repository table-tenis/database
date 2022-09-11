docker-compose up -d
docker exec -it [service-name | service-id] /bin/bash
docker stop/start [service-name | service-id]
docker ps -a --format "table {{.Image}}\t{{.Ports}}\t{{.Names}}" # List short info docker containers
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' [service-name | service-id] # get ipaddress
docker inspect -f '{{.Config.Hostname}}' [service-name | service-id] # get hostname
docker inspect -f '{{range $k,$v:=.HostConfig.PortBindings}}{{range $v}}{{.HostPort}}{{end}}{{end}}' [service-name | service-id] # get portbinding

## If container ip was not in ifconfig
## up link that interface to routing
### check interface of that ip : `ip route`
### up link that interface: `sudo ip link set [interface] up`
### connect to database: `mysql -u root -h $IP -P $PORTBINDING -p password`