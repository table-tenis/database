# **Document For Maria Database**

## **Requirements**

## **Inside Maria Database Management System**
![picture1](images/Picture1.jpg)
*figure 1: inside database management system*

**Inside a maria database server, we have:**
- data directory, log directory, its own process, threads to process requests or inner tasks...
- users (included username and host) for clients connect to server through it
![picture2](images/Picture2.jpg)
*figure 2: client connect to a server*

## **How Replicat Work In MariaDB**
**In Maria Database, we have 3 types of log**
- normal log: files contain logging error or some information about tasks that database server has processed
- bin log: files contain all information about sql query made in the server, included metadata like error codes. Used for master side in replicat
- relay log: files contain information sent by bin log to serve replication. Used for slave side in replicat

**Work Flow Of Replication**
1. first, we need to create a user have replication privilege on some databases or just some tables in a spectific database for slave connect to master. We need some config in this step to slave server complete connect as a slave to its master server. We will show in config section.
2. After complete their connections. IO thread in slave server will send request to its master. These requests will include information about latest position of bin log file in master server. **_Lost Connection:_** After *slave_net_timeout* if slave haven't received response from master, it will consider lost connection and resend the request. If we want send some heartbeat messages to possible reconnect before resend request, we can config *MASTER_HEARTBEAT_PERIOD* less than the *slave_net_timeout* value. The heartbeat interval defaults to half the value of *slave_net_timeout*.
3. Master server send binary logdump to its slave server.
4. IO thread in slave server puts binary logdump into relay log.
5. SQL thread in slave server reads new informations from relay log files and executes queries to synchronize.
![picture1](images/Picture3.jpg)
*figure 3: work flow of replication in mariadb*

## **Config**
**Config MariaDB Replication**
- Create replication in master server
```
$mysql console
create user 'slavename'@'slavehost' identified by 'password';
grant replication slave on database.* to 'slavename'@'slavehost';
flush privileges;
# Get gtid_current_pos in bin log of master server to set it for slave later. Example "0-1-2149"
select @@GLOBAL.gtid_current_pos;
```

- Connect slave server to master server through created replication user
```
$mysql console
stop slave;
reset slave;
set global gtid_slave_pos = "0-1-2149";
change master to master_host='slavehost',master_user='slavename',master_password='password',master_use_gtid=slave_pos;
start slave;
show slave status\G;
```


