#!/bin/sh
###########################################################################
# COPYRIGHT Ericsson 2022
#
# The copyright to the computer program(s) herein is the property of
# Ericsson Inc. The programs may be used and/or copied only with written
# permission from Ericsson Inc. or in accordance with the terms and
# conditions stipulated in the agreement/contract under which the
# program(s) have been supplied.
#
###########################################################################

SCRIPT_NAME="${BASENAME} ${0}"

readonly _ECHO=/bin/echo
readonly _OPENSSL=/usr/bin/openssl
readonly _CUT=/bin/cut
readonly _GREP=/bin/grep
readonly _SED=/bin/sed
readonly _MV=/bin/mv

readonly PRE_START_DIR=/ericsson/3pp/jboss/bin/pre-start/
readonly FILE_TO_ENCRYPT=${PRE_START_DIR}/setup_certm_stores.sh
readonly ENCRYPT_TEXT_KEY=STORE_PASS=
readonly ETC_DOMAINPROXY_DIR=/ericsson/enm/domainproxy/etc
readonly SECURE_DIR=/ericsson/tor/data/domainProxy/.secure
readonly PASSPHRASE_SECURE=${SECURE_DIR}/dp_passphrase.txt
readonly PASSPHRASE_LOCAL=${ETC_DOMAINPROXY_DIR}/dp_passphrase.txt

#///////////////////////////////////////////////////////////////
# output to stderr
#//////////////////////////////////////////////////////////////
error()
{
        >&2 $_ECHO "( ${SCRIPT_NAME} ): $1"
}

#//////////////////////////////////////////////////////////////
# output to stdout
#/////////////////////////////////////////////////////////////
info()
{
        $_ECHO "( ${SCRIPT_NAME} ): $1"
}

#######################################
# Action :
#  __move_passphrase_file
#  Move the passphrase for decoding sensitive data to sfs.
# Globals :
#   PASSPHRASE_LOCAL
#   PASSPHRASE_SECURE
#   SECURE_DIR
# Arguments:
#   None
# Returns:
#
#######################################
__move_passphrase_file() {
    if [ ! -f "${PASSPHRASE_LOCAL}" ]; then
        info "No file to move."
    else
        if ! $_MV ${PASSPHRASE_LOCAL} ${PASSPHRASE_SECURE}; then
            error "Error occurred when moving file ${PASSPHRASE_LOCAL} to ${SECURE_DIR}. Response = $?"
            exit 1
        fi
    fi
}

#######################################
# Action :
#  __encrypt_passphrase_in_file
#  encrypt sensitive data in the file
# Globals :
#   FILE_TO_ENCRYPT
#   ENCRYPT_TEXT_KEY
#   PASSPHRASE_LOCAL
# Arguments:
#   None
# Returns:
#
#######################################
__encrypt_passphrase_in_file() {
    if [ ! -f "${FILE_TO_ENCRYPT}" ]; then
        info "No script to encrypt."
    else
        TEXT_TO_ENCRYPT=$($_GREP $ENCRYPT_TEXT_KEY ${FILE_TO_ENCRYPT} | $_CUT -d '=' -f2-)
        ENCRYPTED_TEXT=$($_ECHO $TEXT_TO_ENCRYPT | $_OPENSSL aes-128-cbc -pass file:${PASSPHRASE_LOCAL} -a -A | $_SED 's#/#\\/#g')
        $_SED -i "s/$TEXT_TO_ENCRYPT/$ENCRYPTED_TEXT/g" ${FILE_TO_ENCRYPT}
        if [ $? -ne 0 ] ; then
            error "Failed to encrypt file ${FILE_TO_ENCRYPT}"
            exit 1
        fi
    fi
}

__encrypt_passphrase_in_file
__move_passphrase_file

exit 0