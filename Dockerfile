###############################################################################################
# This is only one example of how to install and run a tomcat9 docker container. It does not
# target productive use! In order to set up a hardened and production ready tomcat docker 
# container, please see https://github.com/docker-library/tomcat/tree/master/9.0
###############################################################################################
FROM ubuntu:18.04

RUN apt-get update \
  && apt-get install curl

# Java Version
ENV JAVA_VERSION_MAJOR 8
ENV JAVA_VERSION_MINOR 25
ENV JAVA_VERSION_BUILD 17
ENV JAVA_PACKAGE       server-jre
ENV JAVA_CHECKSUM      c3ec171fac394c584a0a5cecb1731efd

# Download, verify and extract Java
RUN curl -kLOH "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
  && echo "${JAVA_CHECKSUM}  ${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz" > ${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz.md5.txt \
  && md5sum -c ${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz.md5.txt \
  && gunzip ${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
  && tar -xf ${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar -C /opt \
  && rm ${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar* \
  && ln -s /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} /opt/jdk

ENV JAVA_HOME /opt/jdk
ENV PATH ${PATH}:${JAVA_HOME}/bin
VOLUME [ "/opt/jdk"]

ENV TOMCAT_MINOR_VERSION 8.0.15
ENV CATALINA_HOME /opt/tomcat

RUN curl -O http://archive.apache.org/dist/tomcat/tomcat-8/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz && \
 curl http://archive.apache.org/dist/tomcat/tomcat-8/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5 | md5sum -c - && \
 gunzip apache-tomcat-*.tar.gz && \
 tar xf apache-tomcat-*.tar && \
 rm apache-tomcat-*.tar && mv apache-tomcat* ${CATALINA_HOME} && \
 rm -rf ${CATALINA_HOME}/webapps/examples \
  ${CATALINA_HOME}/webapps/docs ${CATALINA_HOME}/webapps/ROOT \
  ${CATALINA_HOME}/webapps/host-manager \
  ${CATALINA_HOME}/RELEASE-NOTES ${CATALINA_HOME}/RUNNING.txt \
  ${CATALINA_HOME}/bin/*.bat ${CATALINA_HOME}/bin/*.tar.gz

WORKDIR /opt/tomcat
EXPOSE 8080
EXPOSE 8009
VOLUME [ "/opt/tomcat" ]

ENTRYPOINT [ "/opt/tomcat/bin/catalina.sh" ]
CMD [ "run"]