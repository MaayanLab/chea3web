FROM tomcat:9

COPY docker/chea3.war /usr/local/tomcat/webapps/chea3.war

ENV JAVA_OPTS="-Xmx3G"

CMD ["catalina.sh", "run"]

EXPOSE 8080