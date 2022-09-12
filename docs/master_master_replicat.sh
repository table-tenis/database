## First create master-slave replication in one direction
## We call Master1-Master2
# Add this to /etc/mysql/my.cnf in both server
## Prerequisites for setting up MySQL Slave Replication
# Install mariadb-server and Percona XtraBackup in both server
[mysqld]
server-id=1 # 2 for Master2
bind-address = hostofmaster # address of host
log_bin=/var/log/mysql/mariadb-bin
binlog_format = row
gtid_strict_mode=1

sudo systemctl restart mariadb

## Step 1: create backup data using xtrabackup 
# ----------------- IN Master1$ ------------------
xtrabackup --backup --user=db_user --password=db_password --target-dir=/dir11/backupdir/fullbackup
#xtrabackup: completed OK!
xtrabackup --user=db_user --password=db_password --prepare --target-dir=/dir11/backupdir/fullbackup # Fail in present
# Restore the backup to Slave Server
rsync -avpP -e ssh /dir11/backupdir/fullbackup Master2:/home/backupdirname/

# ----------------- IN Master2$ ------------------
# If you want backup data in Master2. Move it to other directory
mv /var/lib/mysql/datadir /mysql-datadir_bakup

# Move snapshot from Master1 to default datadir in Master2
xtrabackup --move-back --target-dir=/home/backupdirname/fullbackup
# Make sure MySQL has permissions to access them
sudo chown -R mysql:mysql /var/lib/mysql/

## Step 2: Configuring MySQL Replication
# In Mysql Master1
mysql -u admin -p
create user 'master2_user_name'@'master2host' identified by 'password';
grant replication slave on *.* to 'master2_user_name'@'master2host';
flush privileges;
# Get gtid_current_pos in Master1 to set it for Master2 later. Ex "0-1-2149"
select @@GLOBAL.gtid_current_pos;

# Config Slave Node in Mysql Master2
mysql -u admin -p
stop slave;
reset slave;
set global gtid_slave_pos = "0-1-2149";
change master to master_host='master1host',master_user='master2_user_name',master_password='password',master_use_gtid=slave_pos;
start slave;
show slave status\G;
# This finishs config replicatin from Master1 to Master2
# To get opposite direct replication from Master2 to Master 1
# Do the same Step 2 but reverse Master1 vs Master2

## Step 3: Configuring Master2-Master1 Replication
# In Mysql Master2
mysql -u admin -p
create user 'master1_user_name'@'master1host' identified by 'password';
grant replication slave on *.* to 'master1_user_name'@'master1host';
flush privileges;
# Get gtid_current_pos in Master2 to set it for Master1 later. Ex "0-2-3321"
select @@GLOBAL.gtid_current_pos;

# Config Slave Node in Mysql Master1
mysql -u admin -p
stop slave;
reset slave;
set global gtid_slave_pos = "0-2-3321";
change master to master_host='master2host',master_user='master1_user_name',master_password='password',master_use_gtid=slave_pos;
start slave;
show slave status\G;

## Config importance
set global slave_net_timeout=10 # This set 10s for slave resend request events to master
stop slave;
change master to master_heartbeat_period=5;
start slave;
SHOW STATUS LIKE '%heartbeat%';
Show variables like '%slave_net_timeout%';
## To change permanently. Config in /etc/mysql/my.conf file
wait_timeout = 172800
interactive_timeout = 172800
max_allowed_packet = 524288000
slave_net_timeout = 3000

# After set slave_net_timeout, we net reset master_heartbeat_period because it's value is less than slave_net_timeout

## Move datadir mariadb to other partion if /var/lib/mysql default dir is full
# Mount new partion and create new folder to store database such as /db
sudo systemctl stop mariadb
# sync all data to new dir
sudo rsync -avzh /var/lib/mysql/ /db
# add mysql owner for /db
chown --reference=/var/lib/mysql   /db
chmod --reference=/var/lib/mysql   /db
# alias path to new dir. open apparmor alias file
sudo nano /etc/apparmor.d/tunables/alias
# add line 
alias /var/lib/mysql -> /db,
# restart apparmor
sudo systemctl restart apparmor
# change datadir path in mariadb config file
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
# in line datadir = /var/lib/mysql. Change to datadir = /db
# restart mariadb
sudo systemctl start mariadb
# if start error. Fix it by change ProtectHome=true -> ProtectHome=false in /lib/systemd/system/mariadb.service file
# and reload systemctl
sudo systemctl daemon-reload
# restart mariadb

### Create CA-Certificate, Server-Certificate and  Server-key for Mariadb Server 
sudo mkdir -p /etc/mysql/certs && cd /etc/mysql/certs
# create CA-certificate
openssl genrsa 2048 > ca-key.pem
openssl req -new -x509 -nodes -days 365000 -key ca-key.pem -out ca-cert.pem
# create Server-Key and Server-Certificate
openssl req -newkey rsa:2048 -days 365000 -nodes -keyout server-key.pem -out server-req.pem
openssl rsa -in server-key.pem -out server-key.pem
openssl x509 -req -in server-req.pem -days 365000 -CA ca-cert.pem -CAkey ca-key.pem -set_serial 01 -out server-cert.pem
# create Client-Key and Client-Certificate
openssl req -newkey rsa:2048 -days 365000 -nodes -keyout client-key.pem -out client-req.pem
openssl rsa -in client-key.pem -out client-key.pem
openssl x509 -req -in client-req.pem -days 365000 -CA ca-cert.pem -CAkey ca-key.pem -set_serial 01 -out client-cert.pem
# Vertify Certificates
openssl verify -CAfile ca-cert.pem server-cert.pem client-cert.pem
# See content certificates, keys
openssl rsa -text -in server-key.pem
openssl x509 -text -in server-cert.pem
# Change owner of certs folder to mysql
chown -R mysql:mysql /etc/mysql/certs
# Config server to certificate server-side public key in server-certificate
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
# add these lines in the Security Features part
ssl-ca=/etc/mysql/certs/ca-cert.pem
ssl-cert=/etc/mysql/certs/server-cert.pem
ssl-key=/etc/mysql/certs/server-key.pem
# Restart mariadb
sudo systemctl restart mariadb

## In Client-Side. To Create  TLS Data Transfer in One-Way Connection. Config the 50-client.conf
sudo nano /etc/mysql/mariadb.conf.d/50-client.cnf
# add these lines in the Security Features part
ssl
