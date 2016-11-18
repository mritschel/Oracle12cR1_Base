#!/bin/bash
##########################################################################
#  Author   M. Ritschel 
#           Trivadis GmbH Hamburg
#  Created: 28.09.2016 
#  Base-information 
#  ------------------------
# Start-Script for the Trivadis TVD-ConfMan docker images
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
echo_yellow  "Starting listener and database"
echo_yellow "---------------------------------------------------------------------------"
#su oracle -c '/scripts/startup.sh database'
echo_yellow "Database and Web management console initialized. Please visit"
echo_yellow "   - http://localhost:8080/em"
echo_yellow "   - http://localhost:8080/apex"
echo_yellow "\n"
echo_yellow "---------------------------------------------------------------------------"
