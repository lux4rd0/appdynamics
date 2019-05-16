FROM openjdk:8-jre-slim AS builder

MAINTAINER dave.schmid@appdynamics.com

COPY config-exporter-4.5.7.1-BETA.war /

COPY AppServerAgent-4.5.9.25648.zip /
RUN unzip -oq AppServerAgent-4.5.9.25648.zip -d /tmp

FROM openjdk:8-jre-slim
RUN apt-get update && apt-get -y upgrade && apt-get install -y unzip && apt-get install -y apt-utils && apt-get install -y iproute2 && apt-get install -y procps && apt-get install -y sysstat

COPY --from=builder /tmp /opt/appdynamics/AppServerAgent

COPY --from=builder /config-exporter-4.5.7.1-BETA.war /opt/appdynamics

CMD ["sh", "-c", "java ${APPDYNAMICS_JAVA_AGENT} -Dserver.port=${APP_PROPERTIES_SERVER_PORT} -Duser.authentication.enabled=${APP_PROPERTIES_USER_AUTHENTICATION_ENABLED} -jar /opt/appdynamics/config-exporter-4.5.7.1-BETA.war"]
