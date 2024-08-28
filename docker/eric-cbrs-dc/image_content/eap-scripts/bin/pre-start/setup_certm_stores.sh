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
readonly _KEYTOOL=/usr/java/default/bin/keytool
readonly _OPENSSL=/usr/bin/openssl
readonly _RM=/usr/bin/rm
readonly STORE_PASS=3ric550N
readonly KEYSTORE_DIR=/ericsson/cbrs-dc-sa/keystore
readonly TRUSTSTORE_DIR=/ericsson/cbrs-dc-sa/truststore/
readonly CERTCHAIN_BUNDLE=${KEYSTORE_DIR}/dpchain.pfx
readonly DP_KEYSTORE=${KEYSTORE_DIR}/cbrs-dc-sa-keystore.jks
readonly DP_TRUSTSTORE=${TRUSTSTORE_DIR}/cbrs-dc-sa-truststore.jks
readonly DP_PASSPHRASE=/ericsson/tor/data/domainProxy/.secure/dp_passphrase.txt
readonly ENM_SECRET_DIR=/ericsson/cbrs-dc-sa/certificates/enm
readonly CBRS_DC_SA_ENM_CERT_FILE=${ENM_SECRET_DIR}/tls.crt
readonly CBRS_DC_SA_ENM_PRIVATE_KEY=${ENM_SECRET_DIR}/tls.key
readonly TRUSTED_CA_CERTS=${ENM_SECRET_DIR}/cacerts/${TRUSTED_CERTIFICATES_FILE_NAME}
readonly TRUST_ALIAS=rootca

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
#   Import cacerts from CertM secret to truststore
# Globals:
#   TRUSTED_CA_CERTS
#   STORE_PASS
#   DP_TRUSTSTORE
#   TRUST_ALIAS
# Arguments:
#   None
# Returns:
#
#######################################
__import_trusted_ca_certs_to_truststore() {
    ROOTCACERT_FILE=${TRUSTED_CA_CERTS}
    if [ ! -f "$ROOTCACERT_FILE" ]; then
        info "No certificate to import"
    else
        info "Adding root ca to truststore."
        __decrypt_text $STORE_PASS
        if [ -f "$DP_TRUSTSTORE" ]; then
            info "Deleting root ca cert if exists."
            $_KEYTOOL -delete -alias $TRUST_ALIAS -keystore $DP_TRUSTSTORE -storepass $DECRYPTED_TEXT
        fi
        $_KEYTOOL -noprompt -import -trustcacerts -alias $TRUST_ALIAS -file $ROOTCACERT_FILE -storepass $DECRYPTED_TEXT -keystore $DP_TRUSTSTORE > /dev/null 2>&1
        if [ $? -eq 0 ] ; then
            info "Certificate added to truststore."
            return 0
        else
            error "Failed to add certificate to truststore."
            exit 1
        fi
    fi
}

#######################################
# Action :
#   Import key and crt from CertM secret to
#   keystore
# Globals:
#   CBRS_DC_SA_ENM_PRIVATE_KEY
#   CBRS_DC_SA_ENM_CERT_FILE
#   STORE_PASS
#   DP_KEYSTORE
# Arguments:
#   None
# Returns:
#
#######################################
__import_cbrs_dc_sa_enm_secret() {

    if [ ! -f "$CBRS_DC_SA_ENM_PRIVATE_KEY" ] || [ ! -f "$CBRS_DC_SA_ENM_CERT_FILE" ]; then
        info "No CBRS DC SA files to import, exit script"
        exit 0
    else
        __decrypt_text $STORE_PASS
        $_OPENSSL pkcs12 -export -inkey $CBRS_DC_SA_ENM_PRIVATE_KEY -in $CBRS_DC_SA_ENM_CERT_FILE -password pass:$DECRYPTED_TEXT -out $CERTCHAIN_BUNDLE
        if [ $? -ne 0 ] ; then
            error "Failed to convert certificate chain to PKCS12."
            exit 1
        else
            info "Adding certificate chain to keystore."
            info "Import CBRS DC SA ENM private key to keystore."
            if $_KEYTOOL -noprompt -importkeystore -srckeystore $CERTCHAIN_BUNDLE -srcstoretype pkcs12 -destkeystore $DP_KEYSTORE -deststoretype jks -deststorepass "$DECRYPTED_TEXT" -srcstorepass "$DECRYPTED_TEXT" > /dev/null 2>&1
            then
                info "CBRS DC SA ENM private key added to keystore."
                $_RM -f $CERTCHAIN_BUNDLE
            else
                error "Failed to add CBRS DC SA ENM private key to keystore."
                $_RM -f $CERTCHAIN_BUNDLE
                exit 1
            fi
        fi
    fi
}


#######################################
# Action :
#   Decrypt text.
# Globals:
#   DP_PASSPHRASE
# Arguments:
#  The text to decrypt.
# Returns:
#
#######################################
__decrypt_text() {
  TEXT=$1
  if [ ! -f "${DP_PASSPHRASE}" ]; then
    info "Cannot locate passphrase for encryption."
    exit 1
  else
    DECRYPTED_TEXT=$($_ECHO "$TEXT" | $_OPENSSL aes-128-cbc -d -pass file:$DP_PASSPHRASE -a -A)
    if [ $? -ne 0 ] || [ -z "${DECRYPTED_TEXT}" ]; then
      error "Failed to decrypt text: $TEXT".
      exit 1
    fi
  fi
}

# Check if TLS Certificates environment variable exists, (i.e. check if TLS is enabled), before running the script
if [[ -n ${TRUSTED_CERTIFICATES_FILE_NAME+x} ]]; then
  __import_cbrs_dc_sa_enm_secret
  __import_trusted_ca_certs_to_truststore
fi

exit 0
