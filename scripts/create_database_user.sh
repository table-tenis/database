#!/bin/bash
# Usage: /create_database_user.sh
# This script create specific user of a database for access.

printf "Enter DB_USER:" 
read DB_USER
printf "Enter DB_PASSWORD:" 
read -s DB_PASSWORD
printf "\nEnter DB_HOST:" 
read DB_HOST
printf "Enter DB_PORT:" 
read DB_PORT

echo "========== CREATE DATABASE USER =========="
echo "Supply These Infomations"
printf "Enter username:" 
read USERNAME
printf "Enter user-hostname:" 
read HOSTNAME # should be '%'
while :
do
    printf "Enter password:" 
    read -s PASSWORD
    printf "\nRe-Enter password:" 
    read -s REPASSWORD
    if [ $PASSWORD == $REPASSWORD ]; then
        break
    else
        printf "\nERROR:Incorrect Re-Enter Password"
    fi
done
printf "\nEnter DB_NAME FOR GRANT PRIVILEGES:" 
read DB_NAME
# run sql create user command
mysql --user=$DB_USER --password=$DB_PASSWORD --host=$DB_HOST --port=$DB_PORT -e \
"create user '${USERNAME}'@'${HOSTNAME}' identified by '${PASSWORD}';"
mysql --user=$DB_USER --password=$DB_PASSWORD --host=$DB_HOST --port=$DB_PORT -e \
"grant all privileges on ${DB_NAME}.* to '${USERNAME}'@'${HOSTNAME}';"
