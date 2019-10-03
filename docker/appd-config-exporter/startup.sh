#!/bin/bash

UNIQUE_HOST_ID=$(sed -rn '1s#.*/##; 1s/(.{12}).*/\1/p' /proc/self/cgroup)

JAVA_OPTS="${JAVA_OPTS} -javaagent:/opt/appdynamics/AppServerAgent/javaagent.jar"
JAVA_OPTS="${JAVA_OPTS} -Dappdynamics.agent.uniqueHostId=$UNIQUE_HOST_ID"
JAVA_OPTS="${JAVA_OPTS} -Dserver.port=${APP_PROPERTIES_SERVER_PORT}"
JAVA_OPTS="${JAVA_OPTS} -Dappdynamics.analytics.agent.url=${APPDYNAMICS_ANALYTICS_AGENT_URL}"
JAVA_OPTS="${JAVA_OPTS} -Dappdynamics.jvm.shutdown.mark.node.as.historical=${APPDYNAMICS_NODE_HISTORICAL}"
JAVA_OPTS="${JAVA_OPTS} -Duser.authentication.enabled=${APP_PROPERTIES_USER_AUTHENTICATION_ENABLED}"

java ${JAVA_OPTS} -jar /opt/appdynamics/config-exporter-4.5.12.5-BETA.war
