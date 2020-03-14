# Creates image from ubuntu
FROM ubuntu:16.04
WORKDIR /local/unitime

# Install MySQL server
RUN apt-get update && apt-get install mysql-server

# Install Java8 & Tomcat8
RUN apt-get update && add-apt-repository ppa:webupd8team/java && apt-get install oracle-java8-installer && apt-get install tomcat8
RUN apt-get update && /etc/init.d/tomcat8 stop

# Increase xmx parameter
WORKDIR /etc/default/tomcat8
RUN JAVA_OPTS="-Djava.awt.headless=true -Xmx2g -XX:+UseConcMarkSweepGC"

# Install MySQL JDBC driver
WORKDIR /unitime
RUN wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.38/mysql-connector-java-5.1.38.jar
RUN cp mysql-connector-java-5.1.38.jar /var/lib/tomcat8/lib/

# Install UniTime application
RUN wget https://github.com/UniTime/unitime/releases/download/v4.1.175/unitime-4.1_bld175.zip
RUN unzip unitime-4.1_bldl75.zip -d unitime

# Database stuff
RUN mysql -uroot -p -f <unitime/doc/mysql/schema.sql && mysql -utimetable -punitime <unitime/doc/mysql/woebegon-data.sql
RUN mkdir /var/lib/tomcat8/data
RUN chown tomcat8 /var/lib/tomcat8/data && cp unitime/web/UniTime.war /var/lib/tomcat8/webapps

# Start Tomcat8
CMD /etc/init.d/tomcat8 start

