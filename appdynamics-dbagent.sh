#!/bin/bash
#
# Init file for AppDynamics Database Agent
#
# chkconfig: 2345 60 25
# description: database agent for AppDynamics

#CHANGE ME: Set to the Java install directory
JAVA="/opt/appdynamics/java/bin/java"

#CHANGE ME: Set to the agent's install directory
AGENT_HOME="/opt/appdynamics/dbagent"
AGENT="$AGENT_HOME/db-agent.jar"

AGENT_OPTIONS=""
AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.controller.hostName=<controllerhost>"
AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.controller.port=<port>"
AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.accountAccessKey=<accesskey>"
AGENT_OPTIONS="$AGENT_OPTIONS -Ddbagent.name=<agentname>"

start()
{
#echo "$JAVA $AGENT_OPTIONS -Xmx1536m -jar $AGENT"
nohup $JAVA $AGENT_OPTIONS -Xmx1536m -jar $AGENT > /dev/null 2>&1 &
}

stop()
{
ps -opid,cmd |egrep "[0-9]+ $jJAVA.*db-agent" | awk '{print $1}' | xargs --no-run-if-empty kill -9
}

case "$1" in
start)
start
;;

stop)
stop
;;

restart)
stop
start
;;
*)
echo "Usage: $0 start|stop|restart"
esac
