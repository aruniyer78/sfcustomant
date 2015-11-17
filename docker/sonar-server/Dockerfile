FROM java:openjdk-8u45-jdk

# MAINTAINER David Gageot <david.gageot@sonarsource.com>
maintainer Falk Lehmann, falk.lehmann.bp@nttdata.com

ENV SONARQUBE_HOME /opt/sonarqube

# Http port
EXPOSE 9000

# Database configuration
ENV SONARQUBE_JDBC_USERNAME sonar
ENV SONARQUBE_JDBC_PASSWORD 123qwe
ENV SONARQUBE_JDBC_URL jdbc:mysql://${env:DB_PORT_3306_TCP_ADDR}/sonar?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true&useConfigs=maxPerformance

ENV SONAR_VERSION 5.2

# pub   2048R/D26468DE 2015-05-25
#       Key fingerprint = F118 2E81 C792 9289 21DB  CAB4 CFCA 4A29 D264 68DE
# uid                  sonarsource_deployer (Sonarsource Deployer) <infra@sonarsource.com>
# sub   2048R/06855C1D 2015-05-25
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys F1182E81C792928921DBCAB4CFCA4A29D26468DE

RUN set -x \
	&& cd /opt \
	&& curl -o sonarqube.zip -fSL https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip \
	&& curl -o sonarqube.zip.asc -fSL https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip.asc \
	&& gpg --verify sonarqube.zip.asc \
	&& unzip sonarqube.zip \
	&& mv sonarqube-$SONAR_VERSION sonarqube \
	&& rm sonarqube.zip* \
	&& rm -rf $SONARQUBE_HOME/bin/*

VOLUME ["$SONARQUBE_HOME/data", "$SONARQUBE_HOME/extensions"]

WORKDIR $SONARQUBE_HOME
COPY run.sh $SONARQUBE_HOME/bin/
ENTRYPOINT ["./bin/run.sh"]
