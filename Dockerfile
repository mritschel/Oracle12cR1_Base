##########################################################################
# LICENSE CDDL 1.0 + GPL 2.0
#
# Copyright (c) 1982-2016 Trivadis GmbH. All rights reserved.
#
# Docker Basis Oracle Database
# ------------------------------
# This is the Dockerfile for Oracle Database 12c Release 1 Enterprise Edition
# 
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
# (1) linuxamd64_12102_database_1of2.zip
#     linuxamd64_12102_database_2of2.zip
#     Download Oracle Database 12c Release 1 Enterprise Edition for Linux x64
#     from http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html
#
# Run: 
#      $ docker build -t mritschel/oraclebase:latest . 
#
# Pull base image
# ---------------
##########################################################################

FROM oraclelinux:latest

# Maintainer
# ----------
MAINTAINER Martin RItschel <martin.ritschel@trivadis.com.com>

LABEL Basic oracle 12c.R1 

# Fix sh
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
ENV ORACLE_BASE=/u01/app/oracle  
ENV ORACLE_DATA=$ORACLE_BASE/oradata 
ENV ORACLE_HOME=$ORACLE_BASE/product/12.1.0.2/dbhome_1 
ENV NLS_DATE_FORMAT=DD.MM.YYYY\ HH24:MI:SS 
ENV DBCA_TOTAL_MEMORY=1024
ENV ORACLE_SID=ORCLCDB
ENV ORACLE_HOME_LISTNER=$ORACLE_HOME
ENV SERVICE_NAME=xe.oracle.docker

# ENV for the installations files 
# -------------------------------------------------------------
ENV INSTALL_FILE_1="linuxamd64_12102_database_1of2.zip" 
ENV INSTALL_FILE_2="linuxamd64_12102_database_2of2.zip" 
ENV INSTALL_RSP="db_install.rsp" 
ENV CONFIG_RSP="dbca.rsp.tmpl" 
ENV PWD_FILE="setPassword.sh" 
ENV PERL_INSTALL_FILE="installPerl.sh" 
ENV RUN_FILE="entrypoint.sh"

# Use second ENV so that variable get substituted
# -------------------------------------------------------------
ENV INSTALL_HOME=$ORACLE_BASE/install
ENV SCRIPTS_HOME=$ORACLE_BASE/scripts
ENV PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch/:/usr/sbin:$PATH
ENV LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib 
ENV CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib

# Copy binaries
# -------------------------------------------------------------
RUN mkdir -p $INSTALL_HOME
RUN mkdir -p $SCRIPTS_HOME
COPY software/$INSTALL_FILE_1    $INSTALL_HOME/
COPY software/$INSTALL_FILE_2    $INSTALL_HOME/
COPY scripts/$INSTALL_RSP        $SCRIPTS_HOME/
COPY scripts/$PERL_INSTALL_FILE  $SCRIPTS_HOME/
COPY scripts/$RUN_FILE           $SCRIPTS_HOME/
COPY scripts/$CONFIG_RSP         $SCRIPTS_HOME/
COPY scripts/$PWD_FILE           $SCRIPTS_HOME/
COPY scripts/colorecho           $SCRIPTS_HOME/ 

# Rights to the scripts and installation files 
# -------------------------------------------------------------
RUN chmod -R ug+rwx $INSTALL_HOME
RUN chmod -R ug+rwx $SCRIPTS_HOME

# Setup filesystem and oracle user
# Adjust file permissions, go to /u01/oracle as user 'oracle' to proceed with Oracle installation
# ------------------------------------------------------------
RUN mkdir -p /u01 && \
    mkdir -p $ORACLE_DATA && \
    chmod ug+x $SCRIPTS_HOME/$PWD_FILE && \
    chmod ug+x $SCRIPTS_HOME/$RUN_FILE && \
    groupadd -g 500 dba && \
    groupadd -g 501 oinstall && \
    useradd -d /home/oracle -g dba -G oinstall,dba -m -s /bin/bash oracle && \
    echo oracle:oracle | chpasswd && \
    yum -y install oracle-rdbms-server-12cR1-preinstall unzip wget tar openssl && \
    yum clean all && \
    chown -R oracle:dba $ORACLE_BASE

# Replace place holders
# -------------------------------------------------------------
RUN sed -i -e "s|###ORACLE_EDITION###|EE|g" $SCRIPTS_HOME/$INSTALL_RSP &&        \
    sed -i -e "s|###ORACLE_BASE###|$ORACLE_BASE|g" $SCRIPTS_HOME/$INSTALL_RSP && \
    sed -i -e "s|###ORACLE_HOME###|$ORACLE_HOME|g" $SCRIPTS_HOME/$INSTALL_RSP

# Start oracle installation
# -------------------------------------------------------------
USER oracle

RUN cd $INSTALL_HOME       && \
    unzip $INSTALL_FILE_1  >/dev/null 2>&1 && \
    rm $INSTALL_FILE_1     >/dev/null 2>&1 && \
    unzip $INSTALL_FILE_2  >/dev/null 2>&1 && \
    rm $INSTALL_FILE_2     >/dev/null 2>&1 && \
    $INSTALL_HOME/database/runInstaller -silent -force -waitforcompletion -responsefile $SCRIPTS_HOME/$INSTALL_RSP -ignoresysprereqs -ignoreprereq  && \
    rm -rf $INSTALL_HOME/database             && \
    ln -s $SCRIPTS_HOME/$PWD_FILE $HOME/         && \
    echo "DEDICATED_THROUGH_BROKER_LISTENER=ON"  >> $ORACLE_HOME/network/admin/listener.ora  && \
    echo "DIAG_ADR_ENABLED = off"  >> $ORACLE_HOME/network/admin/listener.ora;

# Check whether Perl is working
# -------------------------------------------------------------
RUN chmod u+x $SCRIPTS_HOME/installPerl.sh && \
    $ORACLE_HOME/perl/bin/perl -v || \ 
    $SCRIPTS_HOME/installPerl.sh

USER root
RUN $ORACLE_BASE/oraInventory/orainstRoot.sh && \
    $ORACLE_HOME/root.sh && \
    rm -rf $INSTALL_HOME

# Set password for root and oracle 
# -------------------------------------------------------------
RUN echo 'geheim' | passwd --stdin root
RUN echo 'geheim' | passwd --stdin oracle


# Set the starting environment
# -------------------------------------------------------------
USER oracle
WORKDIR /home/oracle

EXPOSE 1521 
EXPOSE 5500
EXPOSE 8080

# Startup script to start the database in container
RUN chmod u+x $SCRIPTS_HOME/entrypoint.sh
#ENTRYPOINT ["/u01/app/oracle/scripts/entrypoint.sh"]

# Define default command.
#CMD ["bash"]