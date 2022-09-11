#!/bin/bash
IP="$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' xfacedb)"
PORTBINDING="$(docker inspect -f '{{range $k,$v:=.HostConfig.PortBindings}}{{range $v}}{{.HostPort}}{{end}}{{end}}' xfacedb)"
HOSTNAME="$(docker inspect -f '{{.Config.Hostname}}' xfacedb)"
echo "IP = $IP, PORTBINDING = $PORTBINDING, HOSTNAME = $HOSTNAME"
