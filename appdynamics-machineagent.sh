#!/bin/bash 
# 
# Init file for AppDynamics Machine Agent 
# 
# chkconfig: 2345 60 25 
# description: machine agent for AppDynamics

#CHANGE ME: Set to the Java install directory 
JAVA_HOME=/opt/appdynamics/java

#CHANGE ME: Set to the agent's install directory 
AGENT_HOME="/opt/appdynamics/machineagent"

# CHANGE ME: Set to the machine agent runtime user
# If not running the machine agent as root, we recommend running as
# the same user ID as other applications you are monitoring with
# AppDynamics
RUNUSER=root

# Agent Options 
AGENT_OPTIONS="" 
#AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.applicationName=<application-name>" 
#AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.logging.dir=" 
#AGENT_OPTIONS="$AGENT_OPTIONS -Dmetric.http.listener=true | false 
#AGENT_OPTIONS="$AGENT_OPTIONS -Dmetric.http.listener.port=<port>" 
#AGENT_OPTIONS="$AGENT_OPTIONS -Dserver.name=<hostname>" 
#AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.tierName=<tiername>"
#AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.nodeName=<nodename>"


AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.controller.hostName=<controllerhostname>"
AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.controller.port=<port>"
AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.accountAccessKey=<accesskey>"
AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.sim.enabled=true"
AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.uniqueHostId=<hostid>"


# Derived Constants
JAVA=$JAVA_HOME/bin/java
AGENT="$AGENT_HOME/machineagent.jar"

# Process management constants.
# Do not change unless you are certain of what you are doing.
NAME=$(basename $(readlink -e $0))
PIDFILE=/var/run/$NAME.pid
LOCKFILE=/var/lock/subsys/$NAME

if [ `id -un` == $RUNUSER ] ; then
        function bg_runuser {
                exec nohup $* >/dev/null 2>&1 & echo $!
        }
        function runuser {
                $*
        }
else
        function bg_runuser {
                su -c "exec nohup $* >/dev/null 2>&1 & echo \$!" $RUNUSER
        }
        function runuser {
                su -c "$*" $RUNUSER
        }
fi

_status(){
	local realPID
	local otherPIDs
	local returnvalue

	realPID=$(cat $PIDFILE 2>/dev/null)
	otherPIDs=( $(pgrep -f '^/?(.*/)?java ?.* -jar /?(.*/)?machineagent.jar($| .*$)' | grep -vw "$realPID") )

	if ps -p $realPID >/dev/null 2>&1 ; then
		returnvalue=0;
	else
		if [ -f $PIDFILE ] ; then
			returnvalue=1
		elif [ -f $LOCKFILE ] ; then
			returnvalue=2
		else
			returnvalue=3
		fi
	fi

	if [ "${#otherPIDs[@]}" -gt 0 ] ; then
		echo "\
WARNING: One or more instances of the AppDynamics machine agent are running
outside of this wrapper"
		ps -p ${otherPIDs[@]}
	fi

	return $returnvalue
}


start() 
{
    if ! _status ; then
		local PID
		PID=`bg_runuser $JAVA $AGENT_OPTIONS -jar $AGENT`
		echo $PID > $PIDFILE

		# if the machine agent is going to die an early death due to
		# misconfiguration, it will take about 20 seconds
		sleep 20

		if ps -p $PID >/dev/null 2>&1 ; then
			touch $LOCKFILE
		else
			rm -f $PIDFILE
			echo "ERROR: failed to start $NAME"
			return 7
		fi
	else
		echo "\
AppDynamics machine agent already running and wrapped by
$(readlink -e $0)"
		return 0
	fi
}

stop() 
{
	local returnvalue
	local status
	_status
	status=$?
	if [ -f $LOCKFILE ] ; then
		if [ $status == 0 ] ; then
			kill -9 $(cat $PIDFILE)
			returnvalue=0
		else
			returnvalue=7
		fi
		rm -f $PIDFILE
		rm -f $LOCKFILE
                rm -f /opt/appdynamics/machineagent/monitors/analytics-agent/analytics-agent.id
	else
		echo "\
AppDynamics machine agent not running under
$(readlink -e $0)"
	fi
	return $returnvalue
}


case "$1" in 
	start) 
		start
		exit $?
	;; 
	status) 
     	_status
		exitcode=$?
		if [ "$exitcode" == 0 ] ; then
			echo "\
AppDynamics machine agent running and wrapped by
$(readlink -e $0)"
		else
			echo "\
AppDynamics machine agent not running under
$(readlink -e $0)"
		fi
		exit $exitcode
	;;
	stop) 
	    stop
		exit $?
	;; 

	restart) 
	    stop 
	    start 
	;; 
*) 
     echo "Usage: $0 start|stop|restart" 
esac
