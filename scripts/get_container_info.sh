#!/bin/bash
read -p "mariadb container name:" CONTAINER_NAME 
IP="$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME)"
PORTBINDING="$(docker inspect -f '{{range $k,$v:=.HostConfig.PortBindings}}{{range $v}}{{.HostPort}}{{end}}{{end}}' $CONTAINER_NAME)"
HOSTNAME="$(docker inspect -f '{{.Config.Hostname}}' $CONTAINER_NAME)"
echo "IP=${IP},PORTBINDING=${PORTBINDING}, HOSTNAME=${HOSTNAME}" > mariadb_container_info.conf
