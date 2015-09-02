
# obtain latest alpine linux image
FROM alpine

# upgrade
RUN apk update && apk upgrade && \
	apk add --update mariadb mariadb-client && rm -rf /var/cache/apk/*

# from official mariadb dockerfile
# comment out a few problematic configuration values
# don't reverse lookup hostnames, they are usually another container
RUN sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/my.cnf \
	&& echo 'skip-host-cache\nskip-name-resolve' | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/my.cnf > /tmp/my.cnf \
	&& mv /tmp/my.cnf /etc/mysql/my.cnf

# configure mysql
RUN echo "mysql_install_db --user=mysql" > /tmp/config && \
  	echo "mysqld_safe &" >> /tmp/config && \
  	echo "mysqladmin --silent --wait=30 ping || exit 1" >> /tmp/config && \
  	echo "mysqladmin -u root password 'root'" >> /tmp/config && \
  	sh /tmp/config && \
  	rm -f /tmp/config

# define mountable volumes
VOLUME ["/etc/mysql/my.cnf", "/var/lib/mysql"]


# expose port
EXPOSE 3306


# create entry point
CMD ["mysqld_safe"]

