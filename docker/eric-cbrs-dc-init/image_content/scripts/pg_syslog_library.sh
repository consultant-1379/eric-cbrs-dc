##########################################################################
# COPYRIGHT Ericsson 2022
#
# The copyright to the computer program(s) herein is the property of
# Ericsson Inc. The programs may be used and/or copied only with written
# permission from Ericsson Inc. or in accordance with the terms and
# conditions stipulated in the agreement/contract under which the
# program(s) have been supplied.
##########################################################################

# This script overwrites the original library to replace the use of logger with echo

# Ensure script is sourced
[[ "${BASH_SOURCE[0]}" = "$0" ]] && { echo "ERROR: script $0 must be sourced, NOT executed"; exit 1; }

# default values
: ${SCRIPT_NAME:=$(basename "$0")}
: ${LOG_TAG:="$(hostname -s)"}

# ********************************************************************
# Function Name: info
# Description: prints a info message to stdout.
# Arguments: $* - Info message.
# Return: 0.
# ********************************************************************
function info() {
  [ $# -eq 0 ] && { error "Function ${FUNCNAME[0]} requires at least 1 argument"; exit 1; }
  echo "INFO ${SCRIPT_NAME}: $*"
}

# ********************************************************************
# Function Name: warning
# Description: prints a warning message to stdout.
# Arguments: $* - Warning message.
# Return: 0.
# ********************************************************************
function warning() {
  [ $# -eq 0 ] && { error "Function ${FUNCNAME[0]} requires at least 1 argument"; exit 1; }
  echo "WARNING ${SCRIPT_NAME}: $*"
}

# ********************************************************************
# Function Name: error
# Description: prints a error message to stdout.
# Arguments: $* - Error message.
# Return: 0.
# ********************************************************************
function error() {
  [ $# -eq 0 ] && { error "Function ${FUNCNAME[0]} requires at least 1 argument"; exit 1; }
  echo "ERROR ${SCRIPT_NAME}: $*"
}
