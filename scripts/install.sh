#!/bin/bash
##########################################################################
#  Author   M. Ritschel 
#           Trivadis GmbH Hamburg
#  Created: 28.09.2016 
#  Base-information 
#  ------------------------
# Installation-Script for the Trivadis TVD-ConfMan docker images
#  
##########################################################################
set -e

source /tmp/scripts/colorecho

mkdir -p /entrypoint-initdb.d
# Read Hostname
HOSTNAME=$(cat /etc/hostname)

#if [ ! -d "/opt/oracle/app/product/12.1.0/dbhome_1" ]; then
#   echo_yellow "Database is not installed. Installing..."
#   /tmp/scripts/install.sh
#fi

trap "echo_red '******* ERROR: Something went wrong.'; exit 1" SIGTERM
trap "echo_red '******* Caught SIGINT signal. Stopping...'; exit 2" SIGINT

if [ ! -d "/tmp/install/database" ]; then
	echo_red "Installation files not found. Unzip installation files into mounted(/install) folder"
	exit 1
fi

echo_yellow "Installing Oracle Database 12c"

#su oracle -c "/tmp/install/database/runInstaller -silent -ignorePrereq -waitforcompletion -responseFile /tmp/scripts/db_install.rsp"
#/opt/oracle/oraInventory/orainstRoot.sh
#/opt/oracle/app/product/12.1.0/dbhome_1/root.sh


#Run Oracle root scripts

# clearing
echo "Clearing"
#rm -f /scripts/install.sh
#rm -fr $INSTALL_HOME/*
#rm -f /scripts/start_db.sh
#rm -f /scripts/install_tvd_confman.sh
