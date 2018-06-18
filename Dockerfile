###############################################################################################
# This is only one example of how to install and run a tomcat9 docker container. It does not
# target productive use! In order to set up a hardened and production ready tomcat docker 
# container, please see https://github.com/docker-library/tomcat/tree/master/9.0
###############################################################################################
FROM ubuntu:18.04

# Install default jdk
RUN apt-get update \
  && apt-get install -y default-jdk

# Setup Tomcat environment
RUN apt-get install -y curl \
  && groupadd tomcat \
  && useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

# Install Tomcat 
RUN cd /tmp \
  && curl -O http://apache.mirrors.ionfish.org/tomcat/tomcat-8/v8.5.31/bin/apache-tomcat-8.5.31.tar.gz \
  && mkdir /opt/tomcat \
  && tar xzvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1 \
  && cd /opt/tomcat \
  && chgrp -R tomcat /opt/tomcat \
  && chmod -R g+r conf \
  && chmod g+x conf \
  && chown -R tomcat webapps/ work/ temp/ logs/

ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64/jre
ENV PATH ${PATH}:${JAVA_HOME}/bin
ENV CATALINA_HOME /opt/tomcat

WORKDIR /opt/tomcat
EXPOSE 8080
EXPOSE 8009
VOLUME [ "/opt/tomcat" ]

ENTRYPOINT [ "/opt/tomcat/bin/catalina.sh" ]
CMD [ "run"]