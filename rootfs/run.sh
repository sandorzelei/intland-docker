#!/bin/sh
echo "** Start codeBeamer **"

echo $CB_database_JDBC_Password
echo $CB_database_JDBC_Username
echo $CB_database_JDBC_ConnectionURL

eval "echo \"$(cat /CB/config/configuration.template)\"" > /CB/config/configuration.properties

cat /CB/config/configuration.properties

./CB/bin/startup 

touch /CB/tomcat/logs/cb.txt
tail -f /CB/tomcat/logs/cb.txt
