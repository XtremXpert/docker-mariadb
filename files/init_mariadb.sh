mysql_install_db --user=mysql
mysqld_safe &
mysqladmin --silent --wait=30 ping || exit 1
mysql -uroot --execute="CREATE USER 'admin'@'%' IDENTIFIED BY 'admin';"
mysql -uroot --execute="GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;"
mysqladmin reload
