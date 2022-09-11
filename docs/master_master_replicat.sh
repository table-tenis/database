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
