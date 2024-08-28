#!/bin/bash
###########################################################################
#COPYRIGHT Ericsson 2022
#
# The copyright to the computer program(s) herein is the property of
# Ericsson Inc. The programs may be used and/or copied only with written
# permission from Ericsson Inc. or in accordance with the terms and
# conditions stipulated in the agreement/contract under which the
# program(s) have been supplied.
###########################################################################

LOGGING_PROPERTIES="/ericsson/3pp/jboss/standalone/configuration/logging.properties"
CLI_LOGGING_PROPERTIES="/ericsson/3pp/jboss/bin/jboss-cli-logging.properties"

# Source jboss logger methods
. /ericsson/3pp/jboss/bin/jbosslogger

#Changes the log file used for boot logs before the logging subsystem is initialised
if [ -n "${JBOSS_LOG_DIR}" ]; then
  sed -i 's+handler.FILE.fileName=.*+handler.FILE.fileName='"$JBOSS_LOG_DIR"'/server.log+g' $LOGGING_PROPERTIES
  sed -i 's+handler.FILE.fileName=.*+handler.FILE.fileName='"$JBOSS_LOG_DIR"'/jboss-cli.log+g' $CLI_LOGGING_PROPERTIES

  info "JBOSS log directory changed to: ${JBOSS_LOG_DIR}"
fi

exit 0