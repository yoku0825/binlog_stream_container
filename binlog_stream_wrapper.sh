#!/bin/bash

########################################################################
# Copyright (C) 2021  yoku0825
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
########################################################################


function search_target_binlog
{
  ### If binlog is holded in /target, use latest one of them.
  target_binlog=$(ls /target/*.[0-9]* | tail -1 2> /dev/null)
  echo "Pick target_binlog=$target_binlog from /target directory" >&2
   
  ### No binlog in /target, query to mysqld.
  if [[ -z $target_binlog ]] ; then
    case "$empty_action" in
      "first")
        target_binlog=$($mysql_exec $connect_option -sse "SHOW BINARY LOGS" | head -1 | awk '{print $1}')
        ;;
      "last")
        target_binlog=$($mysql_exec $connect_option -sse "SHOW BINARY LOGS" | tail -1 | awk '{print $1}')
        ;;
      "*")
        ### Something wrong...
        echo "Unexpected empty_action $empty_action , should be [first, last]" >&2
        exit 1
    esac
    echo "Pick target_binlog=$target_binlog via SHOW BINARY LOGS" >&2
  
    ### Can't detect any binlog via SHOW BINARY LOGS
    if [[ -z $target_binlog ]] ; then
      echo "Can't find any binary log by using SHOW BINARY LOGS. " >&2
      echo "Please check log-bin and/or user REPLICATION CLIENT priviledge." >&2
      exit 1
    fi
  fi

  echo $target_binlog
}

### Implicit defaults
mysql_user=""
MYSQL_PWD=""
mysql_socket=""
mysql_host=""
mysql_port=""
empty_action="first"
sleep_interval=10
abort_interval=3
export MYSQL_PWD

[[ -r /target/.envrc ]] && . /target/.envrc

connect_option=""
[[ -n $mysql_user ]] && connect_option="$connect_option -u$mysql_user"
[[ -n $mysql_socket ]] && connect_option="$connect_option -S$mysql_socket"
[[ -n $mysql_host ]] && connect_option="$connect_option -h$mysql_host"
[[ -n $mysql_port ]] && connect_option="$connect_option -P$mysql_port"

mysql_exec="mysql57"
mysqlbinlog_exec="mysqlbinlog57"

version=$($mysql_exec $connect_option -sse "SHOW GLOBAL VARIABLES LIKE 'version'" | awk '{print $2}')

if [[ $version =~ ^8\.0\. ]] ; then
  mysqlbinlog_exec=mysqlbinlog80
fi

cd /target
last_time=$(date +%s)

while true ; do
  target_binlog=$(search_target_binlog)
  $mysqlbinlog_exec $connect_option --raw --stop-never --read-from-remote-server $target_binlog

  ### mysqlbinlog --stop-never runs in foreground. So script reaches here, mysqlbinlog has exited by some reason.
  ### ex.) Connection was killed, mysqld stopped, mysqlbinlog crashed, ..
  this_time=$(date +%s)
  diff_time=$(expr $this_time - $last_time)

  if [[ $diff_time -lt $abort_interval ]] ; then
    echo "mysqlbinlog process is down in $diff_time second. aborting.." >&2
    exit 2
  fi

  echo "mysqlbinlog process is down. script sleeps $sleep_interval seconds and retrying again.." >&2
  sleep $sleep_interval
  last_time=$(date +%s)
done
