# Creates image from ubuntu
FROM ubuntu:16.04
WORKDIR /local/unitime

# Install MySQL server
ENV MYSQL_PWD unitime-psd-sql
RUN apt-get update \
	&& echo "mysql-server mysql-server/root_password password $MYSQL_PWD" | debconf-set-selections \
	&& echo "mysql-server mysql-server/root_password_again password $MYSQL_PWD" | debconf-set-selections \
	&& apt-get install -y mysql-server

# Install Java8 & Tomcat8
RUN apt-get update \
	&& apt-get install -y software-properties-common \
	&& apt-get install -y openjdk-8-jdk \
	&& apt-get install -y tomcat8
RUN apt-get update && /etc/init.d/tomcat8 stop

# Increase xmx parameter
RUN echo "JAVA_OPTS="-Djava.awt.headless=true -Xmx2g -XX:+UseConcMarkSweepGC"" >> /etc/default/tomcat8

# Install MySQL JDBC driver
WORKDIR /unitime
RUN apt-get update \
	&& apt-get install -y wget \
	&& wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.38/mysql-connector-java-5.1.38.jar \
	&& cp mysql-connector-java-5.1.38.jar /var/lib/tomcat8/lib/

# Install UniTime application
RUN wget https://github.com/UniTime/unitime/releases/download/v4.1.175/unitime-4.1_bld175.zip
RUN apt-get update \
	&& apt-get install -y unzip \
	&& unzip unitime-4.1_bld175.zip -d unitime

# Database stuff
RUN /etc/init.d/mysql start \
	&& mysql -uroot -p${MYSQL_PWD} -f <unitime/doc/mysql/schema.sql \
	&& mysql -utimetable -punitime <unitime/doc/mysql/woebegon-data.sql
RUN mkdir /var/lib/tomcat8/data
RUN chown tomcat8 /var/lib/tomcat8/data && cp unitime/web/UniTime.war /var/lib/tomcat8/webapps

# Start Tomcat8
CMD /etc/init.d/tomcat8 start

