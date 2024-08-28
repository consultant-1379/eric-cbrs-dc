ARG OS_BASE_IMAGE_NAME=sles
ARG OS_BASE_IMAGE_REPO=armdocker.rnd.ericsson.se/proj-ldc/common_base_os_release
ARG OS_BASE_IMAGE_TAG

FROM ${OS_BASE_IMAGE_REPO}/${OS_BASE_IMAGE_NAME}:${OS_BASE_IMAGE_TAG}

ARG COMMIT
ARG RSTATE
ARG TIMESTAMP
ARG VERSION

ARG PACKAGE_REPO_URL
ARG SLES_BASE_OS_REPO=sles_base_os_repo
ARG ENM_ISO_REPO_URL
ARG ENM_ISO_REPO_NAME=enm_iso_repo

LABEL \
com.ericsson.product-number="CXU 101 1112" \
com.ericsson.product-revision=$RSTATE \
org.opencontainers.image.title="CBRS DC service Image" \
org.opencontainers.image.created=$TIMESTAMP \
org.opencontainers.image.revision=$COMMIT \
org.opencontainers.image.vendor="Ericsson" \
org.opencontainers.image.version=$VERSION

# TODO USER_ID should this be auto generated? - check ADP DR and with  Eoin & Brendan
ARG USER_ID=280236
RUN echo "$USER_ID:x:$USER_ID:0:An identity for eric-cbrs-dc:/nonexistent:/bin/false" >> /etc/passwd && \
    echo "$USER_ID:!::0:::::" >> /etc/shadow && \
    mkdir -p /var/tmp/rpms

# Have to statically refer to USER_ID - due to https://github.com/moby/moby/issues/35018
COPY --chown=280236:0 image_content/scripts/nonroot/change_permissions.sh /usr/local/bin/change_permissions.sh

# TODO: Remove if Startup/Liveness/Readiness probes are updated
COPY --chown=280236:0 --from=armdocker.rnd.ericsson.se/proj-enm/eric-enm-healthcheck-agent:1.0.0-7 /ericsson/enm_healthcheck/bin/enm_healthcheck.py /ericsson/enm_healthcheck/bin/enm_healthcheck.py

# TODO: Tech Debt! Remove if sles-eap7 (image) content is merged into eap7config (rpm)
COPY --chown=280236:0 image_content/eap-scripts/ /var/tmp/eap-scripts/
COPY --chown=280236:0 image_content/eap-healthcheck/ /var/tmp/eap-healthcheck/
COPY image_content/logger /usr/bin/logger

COPY --chown=280236:0 image_content/dcsa-scripts/dcsa-healthcheck/ /usr/lib/ocf/resource.d/
RUN /usr/bin/chmod 775 /usr/lib/ocf/resource.d/* > /dev/null 2>&1
COPY --chown=280236:0 image_content/rpms/ /var/tmp/rpms/

COPY --chown=280236:0 image_content/entry_point_wrapper.sh /ericsson/cbrs-dc-sa/

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN zypper addrepo -C -G -f ${PACKAGE_REPO_URL}?ssl_verify=no $SLES_BASE_OS_REPO && \
    zypper addrepo -C -G -f ${ENM_ISO_REPO_URL}?ssl_verify=no $ENM_ISO_REPO_NAME && \
    zypper dist-upgrade -y && \
    zypper download ERICenmsgdpmediation_CXP9036117  && \
    zypper install -y hostname \
	shadow \
    sysvinit-tools \
    curl \
    # SLES - previously needed for vmmonitord - is this still required?
    python3 \
    # SLES - python3-pycurl - used by pib, default on rhel, needs to be installed on SLES
    python3-pycurl \
    bind-utils \
    EXTRserverjre_CXP9035480 \
    # EAP & SG RPM Dependencies
    bc \
    libxslt1 \
    # libxml2-tools - xmllint
    libxml2-tools \
    # aaa_base - /etc/rc.status init functions
    aaa_base \
    EXTReap7_CXP9037438 \
    ERICeap7config_CXP9037440 \
    ERICmediationengineapi2_CXP9038435 \
    ERICdpsruntimeapi_CXP9030469 \
    ERICserviceframeworkmodule4_CXP9037453 \
    ERICmodelserviceapi_CXP9030594 \
    ERICmodelservice_CXP9030595 \
    ERICdomainproxypersistence_CXP9035433 \
    ERICdomainproxyservice_CXP9035414 \
    ERICsessionmanagerapi_CXP9031998 \
    ERICnetconfsessionapi_CXP9032052 \
    ERICcbanetconfmanager_CXP9031308 \
    ERICtransportapi_CXP9031610 \
    ERICcryptographyservice_CXP9031013 \
    ERICcryptographyserviceapi_CXP9031014 \
    ERICtlstransportlibrary_CXP9031764 \
    ERICpostgresqljdbc_CXP9031176 \
    logrotate \
    cron \
    ${SLES_BASE_OS_REPO}:postgresql15 && \
    rpm -ivh --replacefiles /var/cache/zypp/packages/enm_iso_repo/ERICenmsgdpmediation_CXP9036117*.rpm --nodeps --noscripts && \
    zypper clean -a && \
    zypper removerepo $SLES_BASE_OS_REPO && \
    zypper removerepo $ENM_ISO_REPO_NAME && \
    # TODO: Tech Debt! Remove if sles-eap7 (image) content is merged into eap7config (rpm)
    cp -r /var/tmp/eap-scripts/* /ericsson/3pp/jboss/ && \
    cp -r /var/tmp/eap-healthcheck/* /usr/lib/ocf/resource.d/ && \
    rm -rf /var/tmp/eap-scripts/ /var/tmp/eap-healthcheck/ && \
    # Following scripts delivered by SG RPM
    #   configure_dns.sh file removed to fix postgres connectivity
    #   oomKillerTuning.sh file removed for unsafe sysctl usage
    #   copy_keystore_files_to_local_dir.sh files removed as not required on SADC
    #   fbProperties.sh, delete_incompatible_files_on_cenm.sh and update_consul.sh files removed as not required on SADC
    #   infinispan_healthcheck.sh file removed as it is not used by DCSA
    rm -f /ericsson/3pp/jboss/bin/pre-start/configure_dns.sh /ericsson/3pp/jboss/bin/pre-start/oomKillerTuning.sh && \
    rm -f /ericsson/3pp/jboss/bin/pre-start/copy_keystore_files_to_local_dir.sh /usr/lib/ocf/resource.d/copy_keystore_files_to_local_dir.sh && \
    rm -f /usr/lib/ocf/resource.d/infinispan_healthcheck.sh && \
    rm -f /ericsson/3pp/jboss/bin/pre-start/fbProperties.sh /ericsson/3pp/jboss/bin/pre-start/update_consul.sh /ericsson/3pp/jboss/bin/pre-start/delete_incompatible_files_on_cenm.sh && \
    # POSTGRES Stuff
    mkdir -p /opt/rh/postgresql92/root/usr/ && \
    ln -s /usr/lib/postgresql15/bin /opt/rh/postgresql92/root/usr/ && \
    # Create /ericsson/tor/data/domainProxy "mountpoint" for ConfigMaps
    mkdir -p /ericsson/tor/data/domainProxy && \
    # HTTPS Certificates
    mkdir -p /ericsson/cbrs-dc-sa/truststore/ && \
    mkdir -p /ericsson/cbrs-dc-sa/keystore/ && \
    mkdir -p /ericsson/cbrs-dc-sa/certificates/enm/cacerts/ && \
    chmod 750 /ericsson/cbrs-dc-sa/truststore/ && \
    chmod 750 /ericsson/cbrs-dc-sa/keystore/ && \
    chmod 750 /ericsson/cbrs-dc-sa/certificates/ && \
    chmod 750 /ericsson/cbrs-dc-sa/certificates/enm/ && \
    chmod 750 /ericsson/cbrs-dc-sa/certificates/enm/cacerts/ && \
    # Non-root
    chgrp root /run/lock && \
    chmod 775 /ericsson/3pp && \
    chmod 770 /usr/bin/logger && \
    # replace jboss_user and jboss as owner and grp to $USER_ID and root respectively in jboss pre-start scripts
    find /ericsson/3pp/jboss/bin/pre-start/*.sh -type f -exec sed -i 's/JBOSS_OWN=jboss_user/'"JBOSS_OWN=$USER_ID"'/g' {} \; && \
    find /ericsson/3pp/jboss/bin/pre-start/*.sh -type f -exec sed -i 's/JBOSS_GRP=jboss/JBOSS_GRP=root/g' {} \; && \
    # replace jboss_user and jboss as owner and grp to $USER_ID and root respectively in jboss privateNetwork scripts
    find /ericsson/3pp/jboss/bin/privateNetwork/*.sh -type f -exec sed -i 's/JBOSS_OWN=jboss_user/'"JBOSS_OWN=$USER_ID"'/g' {} \; && \
    find /ericsson/3pp/jboss/bin/privateNetwork/*.sh -type f -exec sed -i 's/JBOSS_GRP=jboss/JBOSS_GRP=root/g' {} \; && \
    bash /usr/local/bin/change_permissions.sh && \
    find /var/log -exec chmod g=u {} \; && \
    chmod g=u /run /usr/java/default/jre/lib/security/cacerts && \
    chmod u+s /usr/bin/chown && \
    # TODO: Investigate ulimit requirements & handling
    sed -i '$ i\*               -       nofile          10240' /etc/security/limits.conf && \
    sed -i '$ i\*           -       nproc           10240' /etc/security/limits.conf && \
    # Timezone?
    rm -f /etc/localtime && \
    # RHEL to SLES mapping
    mkdir -p /etc/rc.d/init.d/ && \
    ln -s /ericsson/3pp/jboss/bin/initfunctions /etc/init.d/functions && \
    ln -s /ericsson/3pp/jboss/bin/initfunctions /etc/rc.d/init.d/functions && \
    rm /etc/init.d/jboss && \
    # Development hook for deploying new RPMs
    ( [ -z "$(ls -A /var/tmp/rpms/ERICdomainproxyservice_CXP9035414*.rpm 2>/dev/null || echo '' | tr -d '\n')" ] || rm -f /ericsson/3pp/jboss/standalone/deployments/cbsd-domain-coordinator-app* ) && \
    ( [ -z "$(ls -A /var/tmp/rpms/*.rpm 2>/dev/null || echo '' | tr -d '\n')" ] || (rpm -ivh --replacefiles /var/tmp/rpms/*.rpm --nodeps --noscripts && chown $USER_ID /ericsson/3pp/jboss/standalone/deployments/cbsd-domain-coordinator-app* ) ) && \
    # Some prestart scripts use cut
    ln -s /usr/bin/cut /bin/cut

COPY --chown=280236:0 cbo-hardening/cbo-harden.sh /cbo-harden.sh
RUN /cbo-harden.sh \
    && rm /cbo-harden.sh

RUN zypper rm -y shadow

#############################################
# TODO: Remove this MASSIVE TECH DEBT!!!!
#       ROOTCACERT_FILE installed by OpenDJ RPM in ENM into /ericsson/tor/data - not available here
#############################################
RUN sed -i '/^__configure_keystore() {/a \ \ \ \ \ \ \ \ return 0' /ericsson/3pp/jboss/bin/configure_production_env.sh

ENV JAVA_HOME=/usr/java/latest \
    PATH=$PATH:$JAVA_HOME/bin:/sbin:/usr/sbin \
    GLOBAL_CONFIG="/gp/global.properties" \
    ENM_JBOSS_SDK_CLUSTER_ID="dpmediation"

# TODO: Is this needed? If so, check the ports
EXPOSE 8080 9990 9999

USER $USER_ID

COPY --chown=280236:0 image_content/dcsa-scripts/logrotateMessages.conf /etc/logrotate.d/

COPY --chown=280236:0 image_content/dcsa-scripts/logrotate_cron.sh /etc/cron.hourly/

RUN chown 280236:0 /var/lib/misc && chown 280236:0 /etc/cron.hourly &&  \
    chmod +x /etc/cron.hourly/logrotate_cron.sh && chmod 700 /var/lib/misc  \
    && chmod 700 /etc/cron.hourly

ENTRYPOINT ["/ericsson/cbrs-dc-sa/entry_point_wrapper.sh", "/ericsson/3pp/jboss/entry_point.sh"]
