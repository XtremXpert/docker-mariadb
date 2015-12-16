# obtain latest alpine linux image
FROM xtremxpert/docker-alpine:latest

# upgrade
RUN apk -U upgrade && \
	apk --update add \
		mariadb \
		mariadb-client \
	&& \
	rm -fr /var/lib/apk/* && \
	rm -fr /var/cache/apk/*

RUN sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/my.cnf && \
	echo "skip-name-resolve" | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/my.cnf > /tmp/my.cnf && \
	mv /tmp/my.cnf /etc/mysql/my.cnf && \
	echo "skip-host-cache" | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/my.cnf > /tmp/my.cnf && \
	mv /tmp/my.cnf /etc/mysql/my.cnf && \
	echo "bind-address = 0.0.0.0" | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/my.cnf > /tmp/my.cnf && \
	mv /tmp/my.cnf /etc/mysql/my.cnf
RUN /usr/bin/mysqld_safe > /dev/null 2>&1 &
#RUN mysqladmin  --silent --wait=30 ping
RUN mysqladmin --wait=30 ping

RUN mysql -uroot -e "CREATE USER 'homestead'@'%' IDENTIFIED BY 'secret'"
RUN mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'homestead'@'%' WITH GRANT OPTION"
RUN mysql -uroot -e "FLUSH PRIVILEGES"
RUN mysql -uroot -e "CREATE SCHEMA homestead"
RUN mysqladmin -uroot shutdown

#RUN	mysql_install_db --user=mysql
#RUN	mysqld_safe &
#RUN	mysqladmin --silent --wait=30 ping || exit 1
#RUN	mysql -uroot --execute="CREATE USER 'admin'@'%' IDENTIFIED BY 'admin';"
#RUN	mysql -uroot --execute="GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;"
#RUN	mysqladmin reload

# define mountable volumes
VOLUME ["/var/lib/mysql"]

# expose port
EXPOSE 3306

# create entry point
CMD ["mysqld_safe"]
