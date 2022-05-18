FROM tomcat:8.0.36-jre8

RUN rm -rf /usr/local/tomcat/webapps/*
RUN mkdir /usr/local/tomcat/webapps/ROOT
COPY challenge /usr/local/tomcat/webapps/ROOT/
COPY flag.txt /
COPY conf/web.xml /usr/local/tomcat/conf/web.xml

EXPOSE 8080 

CMD ["catalina.sh", "run"]
