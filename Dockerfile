
# obtain latest alpine linux image
FROM alpine:latest

ENV LANG="fr_CA.UTF-8" \
	LC_ALL="fr_CA.UTF-8" \
	LANGUAGE="fr_CA.UTF-8" \
	TZ="America/Toronto" \
	TERM="xterm"
# upgrade
RUN apk -U upgrade && \
	apk --update add \
	tzdata \
		openntpd \
		nano \
		mc \
		mariadb \ 
		mariadb-client \
	&& \
 	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	rm -fr /var/lib/apk/* && \
	rm -fr /var/cache/apk/*
	
RUN sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/my.cnf && \
	echo "skip-name-resolve" | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/my.cnf > /tmp/my.cnf && \
	mv /tmp/my.cnf /etc/mysql/my.cnf && \
	echo "skip-host-cache" | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/my.cnf > /tmp/my.cnf && \
	mv /tmp/my.cnf /etc/mysql/my.cnf && \
	echo "bind-address = 0.0.0.0" | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/my.cnf > /tmp/my.cnf && \
	mv /tmp/my.cnf /etc/mysql/my.cnf 
	
RUN echo "mysql_install_db --user=mysql" > /tmp/config && \
  	echo "mysqld_safe &" >> /tmp/config && \
  	echo "mysqladmin --silent --wait=30 ping || exit 1" >> /tmp/config && \
  	echo "mysql -uroot --execute=\"CREATE USER 'admin'@'%' IDENTIFIED BY 'admin';\"" >> /tmp/config && \
  	echo "mysql -uroot --execute=\"GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;\"" >> /tmp/config && \
  	echo "mysqladmin reload" >> /tmp/config && \
  	sh /tmp/config && \
  	rm -f /tmp/config

# define mountable volumes
VOLUME ["/var/lib/mysql"]

# expose port
EXPOSE 3306

# create entry point
CMD ["mysqld_safe"]

