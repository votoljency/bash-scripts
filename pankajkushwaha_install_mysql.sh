#!/bin/bash
INSTALL_DIR={{install_dir}}
DATADIR={{data_dir}}
INNODB_DIR=$DATADIR/innodb
VERSION='{{mysql_version}}'
SOURCE_DIR={{source_dir}}
#export LANG=zh_CN.UTF-8#Source function library.
. /etc/init.d/functions#camke install mysql5.6.X
install_mysql(){
        #read -p "please input a password for root: " PASSWD
    PASSWD='core2017'
        if [ ! -d $DATADIR ];then
                mkdir -p $DATADIR
        fi
        if [ ! -d $INNODB_DIR ];then
                mkdir -p $INNODB_DIR
        fi
        yum install cmake make gcc gcc-c++  ncurses-devel bison-devel -y
        id mysql &>/dev/null
        if [ $? -ne 0 ];then
                useradd mysql -s /sbin/nologin -M
        fi
        #useradd mysql -s /sbin/nologin -M
        #change datadir owner to mysql
        chown -R mysql.mysql $DATADIR
        cd $SOURCE_DIR
        tar xf $VERSION.tar.gz
        cd $VERSION
        cmake . -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
        -DMYSQL_DATADIR=$DATADIR \
        -DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
        -DDEFAULT_CHARSET=utf8 \
        -DDEFAULT_COLLATION=utf8_general_ci \
        -DWITH_INNOBASE_STORAGE_ENGINE=1 \
        -DWITH_ARCHIVE_STORAGE_ENGINE=1 \
        -DWITH_FEDERATED_STORAGE_ENGINE=1 \
        -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
        -DWITH_PERFSCHEMA_STORAGE_ENGINE=1 \
        -DWITH_PARTITION_STORAGE_ENGINE=1 \
        -DEXTRA_CHARSETS=all \
        -DMYSQL_TCP_PORT=3306make && make install
        if [ $? -ne 0 ];then
                action "install mysql is failed!"  /bin/false
                exit $?
        fi
        sleep 2#copy config and start file
        #/bin/cp /usr/local/mysql/support-files/my-small.cnf /etc/my.cnf
        #modify /etc/my.cnf
        sed -i "s:mysqld =:mysqld = $INSTALL_DIR/bin/mysqld_safe:g" /etc/my.cnf
        sed -i "s:mysqladmin =:mysqladmin = $INSTALL_DIR/bin/mysqladmin:g" /etc/my.cnf
        sed -i "s:datadir =:datadir = $DATADIR:g" /etc/my.cnf
        sed -i "s:slow_query_log_file=:slow_query_log_file=$DATADIR:g" /etc/my.cnf
        sed -i "s:log-error=:log-error=$DATADIR:g" /etc/my.cnf
        sed -i "s:innodb_data_home_dir =:innodb_data_home_dir = $INNODB_DIR:g" /etc/my.cnf
        sed -i "s:innodb_log_group_home_dir =:innodb_log_group_home_dir = $INNODB_DIR:g" /etc/my.cnf
        cp $INSTALL_DIR/support-files/mysql.server /etc/init.d/mysqld
        chmod 700 /etc/init.d/mysqld
        #init mysql
        $INSTALL_DIR/scripts/mysql_install_db  --basedir=$INSTALL_DIR --datadir=$DATADIR --user=mysql
        if [ $? -ne 0 ];then
                action "install mysql is failed!"  /bin/false
                exit $?
        fi
        #check mysql
        /etc/init.d/mysqld start
        if [ $? -ne 0 ];then
                action "mysql start is failed!"  /bin/false
                exit $?
        fi
        chkconfig --add mysqld
        chkconfig mysqld on
        $INSTALL_DIR/bin/mysql -e "update mysql.user set password=password('$PASSWD') where host='localhost' and user='root';"
        $INSTALL_DIR/bin/mysql -e "update mysql.user set password=password('$PASSWD') where host='127.0.0.1' and user='root';"
        #$INSTALL_DIR/bin/mysql -e "delete from mysql.user where password='';"
        $INSTALL_DIR/bin/mysql -e "flush privileges;"
        #/usr/local/mysql/bin/mysql -e "select version();" >/dev/null 2>&1
        if [ $? -eq 0 ];then
                echo "+---------------------------+"
                echo "+------mysql安装完成--------+"
                echo "+---------------------------+"
        fi
        #/etc/init.d/mysqld stop
        #add path
        echo "export PATH=$PATH:$INSTALL_DIR/bin" >> /etc/profile
        source /etc/profile
}
install_mysql