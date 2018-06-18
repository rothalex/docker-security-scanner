###############################################################################################
# This is only one example of how to install and run a tomcat9 docker container. It does not
# target productive use! In order to set up a hardened and production ready tomcat docker 
# container, please see https://github.com/docker-library/tomcat/tree/master/9.0
###############################################################################################
FROM openjdk:10-jre

RUN apt-get -y install tomcat8 \
    && echo "JAVA_HOME=/usr/lib/jvm/java-10-openjdk-amd64" >> /etc/default/tomcat8

EXPOSE 8080

CMD ["service tomcat9 start && tail -f /var/lib/tomcat8/logs/catalina.out"]