# binlog_stream_container

- Docker image for streaming MySQL binlog backup.

# How to start

- Create directory to store binary logs.
  - ex. `mkdir /data/binlog/192_168_1_101`

- Copy envrc_template to the directory, and change the file name to .envrc
  - ex. `cp envrc_template /data/binlog/192_168_1_101/.envrc`

- Set the directoy permission. The directory should be able to read and write by .envrc's owner.
  - ex. `sudo chown -R yoku0825. /data/binlog/192_168_1_101`

- Edit .envrc to connect your MySQL

  - `mysql_user` is MySQL Account name for connecting mysqld and receiving binlog from mysqld. Account needs `REPLICATION CLIENT` and `REPLICATION SLAVE` privileges.
  - `MYSQL_PWD` is password for `mysql_user` 
  - `mysql_socket` is socket-file path, if you use Socket to connect your mysqld.
  - `mysql_host` is IP Address or Hostname(which should be resolved by resolver) of mysqld.
  - `mysql_port` is port number of mysqld.
  - `empty_action` should be `first` or `last`.
    - `first` means "If the script can't find any binary logs in /target, the script starts the first of mysqld's binary log list"
    - `last` means "If the script can't find any binary logs in /target, the script starts the current binary log on mysqld's"
  - `sleep_interval` is "How many seconds the script waits before connection retry"
  - `abort_interval` is "How many seconds the script gives up to retry", the script measures "mysqlbinlog process terminated time" minus "mysqlbinlog process started time".


- Create MySQL account on your MySQL.
  - ex. `CRAETE USER binlog_stream IDENTIFIED BY 'binlog_password';`

- Grant `REPLICATION CLIENT` and `REPLICATION SLAVE` privileges to the account.
  - ex. `GRANT REPLICATION CLIENT, REPLICATION SLAVE ON *.* TO binlog_stream;`

- Build up Docker image.
  - ex. `sudo docker build -t binlog_stream_container .`

- Start container with target volume.
  - ex. `sudo docker run -d -v /data/binlog/192_168_1_101:/target`

