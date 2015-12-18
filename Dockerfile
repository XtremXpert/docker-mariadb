# obtain latest alpine linux image
FROM xtremxpert/docker-alpine:latest

ENV MYSQL_USER="XtremXpert"
ENV MYSQL_PASSWORD="NotAnEasyOne"
ENV MYSQL_ROOT_PASSWORD="EvenAnHarderOne"

COPY docker-entrypoint.sh /

# upgrade
RUN apk -U upgrade && \
	apk --update add \
		mariadb \
		mariadb-client \
	&& \
	chmod u+x /*.sh && \
	rm -fr /var/lib/apk/* && \
	rm -fr /var/cache/apk/*

RUN sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/my.cnf && \
	echo "skip-name-resolve" | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/my.cnf > /tmp/my.cnf && \
	mv /tmp/my.cnf /etc/mysql/my.cnf && \
	echo "skip-host-cache" | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/my.cnf > /tmp/my.cnf && \
	mv /tmp/my.cnf /etc/mysql/my.cnf && \
	echo "bind-address = 0.0.0.0" | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/my.cnf > /tmp/my.cnf && \
	mv /tmp/my.cnf /etc/mysql/my.cnf

RUN /init_mariadb.sh

# define mountable volumes
VOLUME ["/var/lib/mysql"]

# expose port
EXPOSE 3306

# create entry point
CMD ["mysqld"]
