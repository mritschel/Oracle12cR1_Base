#!/bin/bash
##########################################################################
#  Author   M. Ritschel 
#           Trivadis GmbH Hamburg
#  Created: 28.09.2016 
#  Base-information 
#  ------------------------
# Start-Script for the Database
#  
##########################################################################
set -e

alert_log="$ORACLE_BASE/diag/rdbms/$ORACLE_SID/$ORACLE_SID/trace/alert_$ORACLE_SID.log"
listener_log="$ORACLE_BASE/diag/tnslsnr/$HOSTNAME/listener/trace/listener.log"
pfile=$ORACLE_HOME/dbs/init$ORACLE_SID.ora
export PATH=${ORACLE_HOME}/bin:$PATH


		lsnrctl start | while read line; do echo -e "lsnrctl: $line"; done
		sqlplus / as sysdba <<-EOF |
			pro Starting with pfile='$pfile' ...
			startup force pfile='$pfile';
			exec dbms_xdb.sethttpport(8060);
			alter system register;
			exit 0
		EOF
		while read line; do echo -e "sqlplus: $line"; done
		wait $MON_ALERT_PID

