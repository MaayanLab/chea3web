FROM tomcat:9.0.124-jre17-temurin-noble

RUN apt-get update \
    && apt-get upgrade --yes \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --system tomcat \
    && useradd --system --gid tomcat --home-dir /usr/local/tomcat \
        --no-create-home --shell /usr/sbin/nologin tomcat \
    && chown -R tomcat:tomcat /usr/local/tomcat

COPY --chown=tomcat:tomcat docker/chea3.war /usr/local/tomcat/webapps/chea3.war

ENV JAVA_OPTS="-Xmx3G"

USER tomcat

EXPOSE 8080

CMD ["catalina.sh", "run"]
