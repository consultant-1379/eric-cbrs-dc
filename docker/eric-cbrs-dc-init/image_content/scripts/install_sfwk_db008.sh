#!/bin/bash

##########################################################################
# COPYRIGHT Ericsson 2022
#
# The copyright to the computer program(s) herein is the property of
# Ericsson Inc. The programs may be used and/or copied only with written
# permission from Ericsson Inc. or in accordance with the terms and
# conditions stipulated in the agreement/contract under which the
# program(s) have been supplied.
###########################################################################

# This script overwrites the original script to create the databases with postgres user

echo "SFWK_DB: Creating tables and roles in SFWK database"

SFWK_DDL_LOG_FILE=sfwk_install_db.log
DB_TEST=/var/tmp/db_test
INSTALL_PATH_SFWK=/ericsson/sfwk_postgres/db/sfwk/sql
SFWK_SCHEMA_MGMT_SCRIPT="${INSTALL_PATH_SFWK}/sfwk_schema_mgmt.sql"
PIB_PARAMETERS_WITH_STATUS_FILE="/ericsson/sfwk_postgres/db/sfwk/pib_parameters_status.conf"
CREATE_TABLES_SCRIPT="${INSTALL_PATH_SFWK}/create_tables.sql"
PG_SLEEP_INT=5
PG_NUM_TRIES=6
SFWK_PW_FILE=/ericsson/sfwk_postgres/db/sfwk/.sfwkpw
SFWKUG_PW_FILE=/ericsson/sfwk_postgres/db/sfwk/.sfwkugpw
readonly PG_USER=postgres
readonly PG_HOSTNAME=${POSTGRES_SERVICE:-postgresql01}
readonly INSTALL_DIR=${INSTALL_DIR:-/opt/ericsson/pgsql/install}
readonly DB=sfwkdb
PSQL_ERROR_CHECK="could not connect to server\|ERROR"
ZERO_UPDATE="UPDATE 0"
readonly LOG_TAG="SFWK_DB"

source /ericsson/enm/pg_utils/lib/pg_syslog_library.sh
source /ericsson/enm/pg_utils/lib/pg_password_library.sh
source /ericsson/enm/pg_utils/lib/pg_dbcreate_library.sh
source /ericsson/enm/pg_utils/lib/pg_rolecreate_library.sh

if [ $PG_ROOT ];
then
  PG_CLIENT=$PG_ROOT/psql
else
  PG_CLIENT=/opt/rh/postgresql/bin/psql
fi;

logInfo() {
  msg=$1
  echo "`date +[%D-%T]` $msg" &>>$INSTALL_DIR/$SFWK_DDL_LOG_FILE
  info $msg
}

logError() {
  msg=$1
  echo "`date +[%D-%T]` $msg" &>>$INSTALL_DIR/$SFWK_DDL_LOG_FILE
  error $msg
}

#*****************************************************************************#
# Fetches the postgres user password
#*****************************************************************************#
export_password
PG_PASSWORD=$PGPASSWORD

#*****************************************************************************#
# Fetch SFWK passwords
#*****************************************************************************#
SFWK_PASSWORD=$(head -n 1 $SFWK_PW_FILE)
SFWKUG_PASSWORD=$(head -n 1 $SFWKUG_PW_FILE)

#*****************************************************************************#
##Logging & Error Checking Housekeeping
#*****************************************************************************#
if [ -f $INSTALL_DIR/$SFWK_DDL_LOG_FILE ]
then
  LDATE=`date +[%m%d%Y%T]`
  mv $INSTALL_DIR/$SFWK_DDL_LOG_FILE $INSTALL_DIR/$SFWK_DDL_LOG_FILE.$LDATE
  touch  $INSTALL_DIR/$SFWK_DDL_LOG_FILE
  chmod a+w $INSTALL_DIR/$SFWK_DDL_LOG_FILE
else
  touch  $INSTALL_DIR/$SFWK_DDL_LOG_FILE
  chmod a+w $INSTALL_DIR/$SFWK_DDL_LOG_FILE
fi

#*****************************************************************************#
# db_test ()
# Tests for the existence of the sfwkdb Database
# The DB is a pre-requisite
#*****************************************************************************#

function db_test() {
  logInfo  "Database Validation for $DB"

  rm -rf $DB_TEST > /dev/null 2>&1
  su 2> /dev/null - $PG_USER -c "PGPASSWORD=$PG_PASSWORD $PG_CLIENT -h $PG_HOSTNAME-U$PG_USER -t <<EOF >>$DB_TEST
  SELECT datname FROM pg_database;
  EOF
  "
  egrep "^[ ]*$DB[ ]*$" $DB_TEST > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    logInfo "There is currently no $DB on this server wait for ${PG_SLEEP_INT} seconds!!! "
    for (( retry=0 ; retry < $PG_NUM_TRIES ; retry ++ )); do
      su 2> /dev/null - $PG_USER -c "PGPASSWORD=$PG_PASSWORD $PG_CLIENT -h $PG_HOSTNAME -U$PG_USER -t <<EOF >>$DB_TEST
      SELECT datname FROM pg_database;
      EOF
      "
      egrep "^[ ]*$DB[ ]*$" $DB_TEST > /dev/null 2>&1
      if [ $? -eq  0 ]; then
        break
      fi
      sleep $PG_SLEEP_INT
    done
  fi
}

checkExitCode(){
  logInfo "We should not proceed with Postgres Installation due to issue installing $DB"
  exit 1
}

checkForError(){
  return=0
  grep "$PSQL_ERROR_CHECK" $INSTALL_DIR/$SFWK_DDL_LOG_FILE  > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
    case $1 in
      II_Check)
        logError "We should not proceed due to issue checking for initial install"
        return=1
        ;;
      Schema_Update)
        logError "We should not proceed due to issue updating the wfsdb schema with ${SFWK_SCHEMA_MGMT_SCRIPT}"
        return=1
        ;;
      Tables)
        logError "We should not proceed with Postgres Installation due to issue creating Database $DB Tables in PostgreSQL"
        logError "We should not proceed with Postgres Installation due to issue with ${CREATE_TABLES_SCRIPT}"
        return=1
        ;;
      update_pib_status)
        logError "We should not proceed with Postgres Installation due to issue updating pib status in $DB"
        return=1
        ;;
      *)
        logError "We should not proceed due to an unknown issue"
        return=1
        ;;
    esac
  fi
    return $return
}

checkForNoUpdate(){
  grep "$ZERO_UPDATE" $INSTALL_DIR/$SFWK_DDL_LOG_FILE  > /dev/null 2>&1
  if [[ $? -eq 0 ]]; then
    logInfo "Some PIB parameters provided in the input file are not updated as no matching row exists. Please check $INSTALL_DIR/$SFWK_DDL_LOG_FILE for further details"
  fi
}

#*****************************************************************************#
# create_sfwk_role ()                                                         #
# create role sfwk in the sfwkdb                                              #
#-----------------------------------------------------------------------------#
function create_sfwk_role() {
  DB_ROLE='sfwk'
  DB_ROLE_PSW=$SFWK_PASSWORD
  logInfo "Creating Service Framework DB sfwk role"
  if ! role_create 'NOSUPERUSER NOCREATEDB NOCREATEROLE'; then
    logError "SFWKDB Role sfwk creation failed."
    exit 1
  fi
}

#*****************************************************************************#
# create_sfwkug_role ()                                                       #
# create role sfwkug in the sfwkdb                                            #
#-----------------------------------------------------------------------------#
function create_sfwkug_role() {
  DB_ROLE='sfwkug'
  DB_ROLE_PSW=$SFWKUG_PASSWORD
  logInfo "Creating Service Framework DB sfwkug role"
  if ! role_create; then
    logError "SFWKDB Role sfwkug creation failed."
    exit 1
  fi
}

#*****************************************************************************#
# create_roles ()                                                             #
# create all required roles in the sfwkdb                                     #
#-----------------------------------------------------------------------------#
function create_roles() {
  logInfo "Creating Service Framework DB roles"
  create_sfwk_role
  create_sfwkug_role
}

#*****************************************************************************#
# grant_connect_sfwkmgmt_group ()                                             #
# Grants connect privelege for sfwkmgmt group                                 #
# Revokes connect access to sfwkdb from public schema/users                   #
#-----------------------------------------------------------------------------#
function grant_connect_sfwkmgmt_group() {
  DB_ROLE='sfwkmgmt'

  if ! grant_connect_privilege_on_database_for_role; then
    logError "SFWKDB Grant Connect failed."
    exit 1
  fi

  if ! revoke_connect_for_user_on_database; then
    logError "SFWKDB Grant Connect failed."
    exit 1
  fi
}

#*****************************************************************************#
# create_sfwk_tables ()                                                       #
# create all required tables in the sfwkdb                                    #
#-----------------------------------------------------------------------------#
function create_sfwk_tables() {
  logInfo "Creating Service Framework DB tables"

  PGPASSWORD=$PG_PASSWORD $PG_CLIENT -h $PG_HOSTNAME -U$PG_USER -d$DB -f ${CREATE_TABLES_SCRIPT} >> $INSTALL_DIR/$SFWK_DDL_LOG_FILE 2>&1
  checkForError 'Tables' || checkExitCode
  logInfo "Created Service Framework DB tables successfully"
}

#*****************************************************************************#
# initial_install_check ()                                                    #
# Check if eservice_info table is present in the public schema.               #
# If no tables are present, this indicates it is an initial install           #
#*****************************************************************************#
function initial_install_check() {
if [ -z "$SFWK_INITIAL_INSTALL" ]; then
  table_exists_query="SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'eservice_info';"
  PGPASSWORD=$PG_PASSWORD $PG_CLIENT -h $PG_HOSTNAME -U$PG_USER -d$DB -c "$table_exists_query" >> $INSTALL_DIR/$SFWK_DDL_LOG_FILE 2>&1
  checkForError 'II_Check' || checkExitCode

  if [ $(grep -c "(1 row)" $INSTALL_DIR/$SFWK_DDL_LOG_FILE) -eq 1 ]; then
    export SFWK_INITIAL_INSTALL=false;
  else
    export SFWK_INITIAL_INSTALL=true;
  fi;
fi
logInfo "Initial install $SFWK_INITIAL_INSTALL"
}


#**************************************************************#
# update_schema ()
# invoke PL/PGSQL script to perform updates on the sfwkdb schema
#**************************************************************#
function update_schema() {
  logInfo "Create update_schema function to update sfwkdb schema"
  PGPASSWORD=$PG_PASSWORD $PG_CLIENT -h $PG_HOSTNAME -U$PG_USER -d$DB -f ${SFWK_SCHEMA_MGMT_SCRIPT} >> $INSTALL_DIR/$SFWK_DDL_LOG_FILE 2>&1
  checkForError 'Schema_Update' || checkExitCode

  logInfo "Execute update_schema function"
  PGPASSWORD=$PG_PASSWORD $PG_CLIENT -h $PG_HOSTNAME -U$PG_USER -d$DB -c "Select update_schema('$SFWK_PASSWORD','$SFWKUG_PASSWORD')" >> $INSTALL_DIR/$SFWK_DDL_LOG_FILE 2>&1
  checkForError 'Schema_Update' || checkExitCode

  logInfo "Updated sfwkdb schema successfully"
}

#*************************************************************************************************************************#
# update_pib_parameters_status ()                                                                                         #
# The status of the PIB parameters defined in $PIB_PARAMETERS_WITH_STATUS_FILE will be changed to the provided status     #
# If no status is provided then default status CREATED_NOT_MODIFIED is used                                               #
# If no service identifier is provided then all the pib parameters with matching name are considered                      #
#*************************************************************************************************************************#
function update_pib_parameters_status() {
  logInfo "Updating the provided PIB parameters status"
  while read -r entry; do
    if [[ -n "$entry" ]] && [[ ${entry} != [#]* ]]; then
      entryArray=(${entry})
      name=${entryArray[0]}
      status=${entryArray[1]}
      service_identifier=${entryArray[2]}
      if [[ -n "$status" && ${status} != "MODIFIED" && ${status} != "CREATED_NOT_MODIFIED" && -z ${service_identifier} ]]; then
        service_identifier=${status}
        status="CREATED_NOT_MODIFIED"
      elif [[ ${status} != "MODIFIED" && ${status} != "CREATED_NOT_MODIFIED" ]]; then
        status="CREATED_NOT_MODIFIED"
      fi
      update_status_command="UPDATE configuration_parameter SET status='${status}' WHERE name='${name}'"
      if [[ -n "$service_identifier" ]]; then
        update_status_command="${update_status_command} AND service_identifier='${service_identifier}'"
      fi
      logInfo "Updating pib parameter with name: [${name}] and service identifier: [${service_identifier}] status to [${status}]"
      PGPASSWORD=$PG_PASSWORD $PG_CLIENT -h $PG_HOSTNAME -U$PG_USER -d$DB -c "$update_status_command" >> $INSTALL_DIR/$SFWK_DDL_LOG_FILE 2>&1
      checkForError 'update_pib_status' || checkExitCode
    fi
  done <${PIB_PARAMETERS_WITH_STATUS_FILE}
  checkForNoUpdate
  logInfo "Updated the provided PIB parameters status"
}

##MAIN
createDb
initial_install_check
if ${SFWK_INITIAL_INSTALL}; then
  create_sfwk_tables
fi
create_roles
update_schema
grant_connect_sfwkmgmt_group
update_pib_parameters_status
