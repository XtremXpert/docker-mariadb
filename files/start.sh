#!/bin/bash

if [ ! -d /var/lib/mysql/mysql ]; then
	echo "Populating DataDir ... "
	mysql_install_db --user=mysql &> /dev/null
fi

if [[ -z ${MYSQL_ROOT_PASSWORD} ]]; then
	MYSQL_ROOT_PASSWORD=$(pwgen -s -1 12)
	echo "Your Root password is : ${MYSQL_ROOT_PASSWORD}"
fi

echo "Initializing Root password ... "
/usr/bin/mysqld_safe --log-error=/tmp/init.log --skip-networking --skip-grant-tables &> /dev/null &
sleep 2
echo -e "\n\n${MYSQL_ROOT_PASSWORD}\n${MYSQL_ROOT_PASSWORD}\n\n\nn\n\n\n" | mysql_secure_installation &> /dev/null

if [[ -n ${MYSQL_DATABASE} ]]; then

	echo -ne "Creating ${MYSQL_DATABASE} Database ... "
	mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
	echo "Done"
fi

if [[ -n ${MYSQL_USER} && -n ${MYSQL_PASSWORD} ]]; then

	MYSQL_USER_HOST=${MYSQL_USER_HOST:-%}

	if [[ -n ${MYSQL_DATABASE} ]]; then
		echo -ne "GRANT PRIVILEGES on ${MYSQL_DATABASE} to ${MYSQL_USER}@'${MYSQL_USER_HOST}' user ... "
		SQL="GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* to ${MYSQL_USER}@'${MYSQL_USER_HOST}' identified by '${MYSQL_PASSWORD}';"
	else
		echo -ne "Creating ${MYSQL_USER} Database with grant to ${MYSQL_USER}@${MYSQL_USER_HOST} ... "
		SQL="CREATE DATABASE IF NOT EXISTS ${MYSQL_USER}; GRANT ALL PRIVILEGES ON ${MYSQL_USER}.* to ${MYSQL_USER}@'${MYSQL_USER_HOST}' identified by '${MYSQL_PASSWORD}';"
	fi

	mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "$SQL FLUSH PRIVILEGES;"
	echo "Done"

fi

/usr/bin/mysqladmin -u root --password=${MYSQL_ROOT_PASSWORD} shutdown
sleep 2
history -c
echo "Starintg MariaDB ..."
tail -f /var/log/mariadb/mariadb.log &
/usr/bin/mysqld_safe