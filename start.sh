#!/bin/bash

sudo /usr/sbin/sshd
datapath=/home/adb/data/antdb40

mkdir -p $datapath
antdb_oid=`cat /etc/passwd|grep antdb:|awk -F ':' '{print $3}' `
antdb_gid=`cat /etc/passwd|grep antdb:|awk -F ':' '{print $4}' `
is_empty_dir(){ 
    return `ls -A $1|wc -w`
}
#数据路径为空，则只需initdb操作
if is_empty_dir $datapath  > /dev/null 2>&1
then
    echo "${ADB_PASSWORD}" > /tmp/passwordfile.txt
    /opt/app/adb/bin/initdb -D $datapath -E UTF8 --locale=C -k --pwfile=/tmp/passwordfile.txt
    cat  >>  $datapath/postgresql.conf << EOF
listen_addresses = '*'
port = 5432
max_prepared_transactions = 300
log_destination = 'csvlog'
logging_collector = 'on'
log_directory = 'pg_log'
log_statement = 'none'
log_truncate_on_rotation = 'on'
EOF
    sed -i '$a\host    all             all             0.0.0.0/0               md5' $datapath/pg_hba.conf
fi
#数据库路径非空，则只需启动数据库操作
/opt/app/adb/bin/pg_ctl start -D $datapath -o -i -w -c -W -l $datapath/logfile
