#!/bin/bash
# Usage: /create_root_account.sh
# This script create a first root user in database for xface system.

printf "Enter DB_USER:" 
read DB_USER
printf "Enter DB_PASSWORD:" 
read -s DB_PASSWORD
printf "\nEnter DB_HOST:" 
read DB_HOST

echo "<<<<<<<<< CREATE ROOT ACCOUNT >>>>>>>>>>"
echo "Supply These Infomations"
printf "Enter username:" 
read USERNAME
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
printf "\nEnter email:" 
read EMAIL
printf "Enter cellphone:" 
read CELLPHONE
printf "Enter something note:" 
read NOTE

# sql command
echo "Add a root account into database"
HASH_PASSWD="$(value=$PASSWORD python3 - <<END
import argon2
import os
argon2Hasher = argon2.PasswordHasher(
        time_cost=3, # number of iterations
        memory_cost=64 * 1024, # 64mb
        parallelism=1, # how many parallel threads to use
        hash_len=32, # the size of the derived key
        salt_len=16 # the size of the random generated salt in bytes
        )
hash_passwd = argon2Hasher.hash(os.environ['value'])
print(hash_passwd)
END
)"

# run sql insert command
mysql --user=$DB_USER --password=$DB_PASSWORD --host=$DB_HOST xface << EOF
INSERT INTO account \
 (\`username\`, \`password\`, \`email\`, \`cellphone\`, \`note\`, \`is_root\`) \
VALUES ("$USERNAME", "$HASH_PASSWD", "$EMAIL", "$CELLPHONE", "$NOTE", True);
EOF
