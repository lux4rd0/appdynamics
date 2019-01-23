FROM openjdk:8-jre-slim AS builder

MAINTAINER dave.schmid@appdynamics.com

COPY MachineAgent.zip /
RUN unzip -oq MachineAgent.zip -d /tmp 

FROM openjdk:8-jre-slim
RUN apt-get update && apt-get -y upgrade && apt-get install -y unzip && apt-get install -y apt-utils && apt-get install -y iproute2 && apt-get install -y procps && apt-get install -y sysstat
COPY --from=builder /tmp /opt/appdynamics

CMD ["sh", "-c", "java ${MACHINE_AGENT_PROPERTIES} -jar /opt/appdynamics/machineagent.jar"]
