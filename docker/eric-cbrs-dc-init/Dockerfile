ARG OS_BASE_IMAGE_NAME=sles
ARG OS_BASE_IMAGE_REPO=armdocker.rnd.ericsson.se/proj-ldc/common_base_os_release
ARG OS_BASE_IMAGE_TAG

FROM ${OS_BASE_IMAGE_REPO}/${OS_BASE_IMAGE_NAME}:${OS_BASE_IMAGE_TAG}

ARG COMMIT
ARG RSTATE
ARG TIMESTAMP
ARG VERSION

LABEL \
com.ericsson.product-number="CXU 101 1113" \
com.ericsson.product-revision=$RSTATE \
org.opencontainers.image.title="CBRS DC service init Image" \
org.opencontainers.image.created=$TIMESTAMP \
org.opencontainers.image.revision=$COMMIT \
org.opencontainers.image.vendor="Ericsson" \
org.opencontainers.image.version=$VERSION

ARG PACKAGE_REPO_URL
ARG SLES_BASE_OS_REPO=sles_base_os_repo
ARG ENM_ISO_REPO_URL
ARG ENM_ISO_REPO_NAME=enm_iso_repo

RUN zypper addrepo -C -G -f ${PACKAGE_REPO_URL}?ssl_verify=no $SLES_BASE_OS_REPO && \
    zypper addrepo -C -G -f ${ENM_ISO_REPO_URL}?ssl_verify=no $ENM_ISO_REPO_NAME

ARG USER_ID=205404
RUN echo "$USER_ID:x:$USER_ID:0:An Identity for eric-cbrs-dc-init:/nonexistent:/bin/false" >> /etc/passwd && \
    echo "$USER_ID:!::0:::::" >> /etc/shadow

RUN zypper dist-upgrade -y && \
    zypper download ERICserviceframeworkdb_CXP9032274 && \
    zypper install -y curl \
    sles_base_os_repo:postgresql15 \
    ERICpostgresutils_CXP9038493 && \
    rpm -ivh /var/cache/zypp/packages/enm_iso_repo/ERICserviceframeworkdb_CXP9032274*.rpm --nodeps --noscripts && \
    zypper clean --all && \
    rm -f /var/log/zypper.log

RUN zypper install -y shadow && \
    zypper clean -a && \
    rm -f /var/log/zypper.log && \
    mkdir -p /opt/rh/postgresql92/root/usr/ && \
    ln -s /usr/lib/postgresql15/bin /opt/rh/postgresql92/root/usr/ && \
    /usr/bin/chmod 775 /ericsson/sfwk_postgres/db/sfwk > /dev/null 2>&1

COPY --chown=205404:0 image_content/scripts/* /var/tmp/
COPY image_content/scripts/pg_syslog_library.sh /ericsson/enm/pg_utils/lib/pg_syslog_library.sh
COPY image_content/scripts/install_sfwk_db008.sh /ericsson/sfwk_postgres/db/sfwk/install_sfwk_db008.sh
RUN /usr/bin/chmod 775 /ericsson/sfwk_postgres/db/sfwk/install_sfwk_db008.sh > /dev/null 2>&1

COPY --chown=205404:0 cbo-hardening/cbo-harden.sh /cbo-harden.sh
RUN /cbo-harden.sh \
    && rm /cbo-harden.sh
	
ENV PG_ROOT /usr/lib/postgresql15/bin
ENV INSTALL_DIR /ericsson/sfwk_postgres/db/sfwk

USER $USER_ID

CMD ["/usr/bin/sleep","2"]
