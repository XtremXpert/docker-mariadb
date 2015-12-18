#!/bin/sh
DATADIR="$(mysqld --verbose --help 2>/dev/null | awk '$1 == "datadir" { print $2; exit }')"

if [ ! -d "$DATADIR/mysql" ]; then

    mysql_install_db --user=mysql

    /usr/bin/mysqld_safe  &
    sleep 10s

		#Changed mysql_secure_installation script to running only the commands.
		echo "UPDATE mysql.user SET Password=PASSWORD('${DB_ROOT_PASS}') WHERE User='root'; DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'); DELETE FROM mysql.user WHERE User=''; DROP DATABASE test; FLUSH PRIVILEGES;" | mysql -u root


    echo "GRANT ALL ON *.* TO ${DB_USER}@'127.0.0.1' IDENTIFIED BY '${DB_PASS}' WITH GRANT OPTION; GRANT ALL ON *.* TO ${DB_USER}@'localhost' IDENTIFIED BY '${DB_PASS}' WITH GRANT OPTION; GRANT ALL ON *.* TO ${DB_USER}@'::1' IDENTIFIED BY '${DB_PASS}' WITH GRANT OPTION; FLUSH PRIVILEGES;" | mysql -u root --password="${DB_ROOT_PASS}"

    killall mysqld
    killall mysqld_safe
    sleep 10s
    killall -9 mysqld
    killall -9 mysqld_safe
fi

mysqld --user=mysql
