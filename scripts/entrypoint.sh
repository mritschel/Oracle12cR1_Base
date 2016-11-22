#!/bin/bash
##########################################################################
#  Author   M. Ritschel 
#           Trivadis GmbH Hamburg
#  Created: 28.09.2016 
#  Base-information 
#  ------------------------
# Start-Script for the Oracle Base docker images
#  
##########################################################################
set -e

source $SCRIPTS_HOME/colorecho

# Add oracle to path
export PATH=${ORACLE_HOME}/bin:$PATH
if grep -q "PATH" ~/.bashrc
then
    echo "Found PATH definition in ~/.bashrc"
else
	echo "Extending PATH in in ~/.bashrc"
	printf "\nPATH=${PATH}\n" >> ~/.bashrc
fi

echo "\n \n \n"
echo_green  "The server is started and ready"
echo_green "---------------------------------------------------------------------------"
echo_green "Oracle Server 12c R1 is under $ORACLE_HOME installed"
echo_green "\n"
echo_green "---------------------------------------------------------------------------"
