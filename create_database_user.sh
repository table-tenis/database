#!/bin/bash
# Usage: /create_database_user.sh
# This script create specific user of a database for access.

# run sql create user command
USER='root'
PASSWORD='root'
HOST='172.21.0.1'
PORT=3308
mysql --user=$USER --password=$PASSWORD --host=$HOST --port=$PORT -e \
"create user 'user1'@'%' identified by 'password';"
mysql --user=$USER --password=$PASSWORD --host=$HOST --port=$PORT -e \
"grant all privileges on xface_system.* to 'user1'@'%';"
