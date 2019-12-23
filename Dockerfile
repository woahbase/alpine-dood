# syntax=docker/dockerfile:1
#
ARG IMAGEBASE=frommakefile
#
FROM ${IMAGEBASE}
#
ARG BUILDXVERSION
ARG BUILDXARCH
#
ARG COMPOSEVERSION
ARG COMPOSEARCH
#
# ARG MACHINEVERSION
# ARG MACHINEARCH
#
RUN set -xe \
    && apk add -Uu --purge --no-cache \
        curl \
        ctop \
        docker-cli \
        # docker-cli-buildx \
        # docker-cli-compose \
        docker-credential-ecr-login \
        git \
        # jq \
        make \
        openssh \
        skopeo \
        # yq \
    && mkdir -p /usr/libexec/docker/cli-plugins/ \
#
    && if [ -n "${BUILDXVERSION}" ] && [ -n "${BUILDXARCH}" ]; \
    then \
        echo "using buildx version: $BUILDXVERSION / $BUILDXARCH" \
        && curl -jSLN \
            -o /usr/libexec/docker/cli-plugins/docker-buildx \
            https://github.com/docker/buildx/releases/download/v${BUILDXVERSION}/buildx-v${BUILDXVERSION}.${BUILDXARCH} \
        && chmod a+rx /usr/libexec/docker/cli-plugins/docker-buildx; \
    fi \
#
    && if [ -n "${COMPOSEVERSION}" ] && [ -n "${COMPOSEARCH}" ]; \
    then \
        echo "using compose version: $COMPOSEVERSION / $COMPOSEARCH" \
        && curl -jSLN \
            -o /usr/libexec/docker/cli-plugins/docker-compose \
            https://github.com/docker/compose/releases/download/v${COMPOSEVERSION}/docker-compose-${COMPOSEARCH} \
        && ln -sfv \
            /usr/libexec/docker/cli-plugins/docker-compose \
            /usr/local/bin/docker-compose \
        && chmod a+rx \
            /usr/libexec/docker/cli-plugins/docker-compose \
            /usr/local/bin/docker-compose; \
    fi \
#
# # disabled since docker-machine is now deprecated
#     && if [ -n "${MACHINEVERSION}" ] && [ -n "${MACHINEARCH}" ]; \
#     then \
#         echo "using machine version: $MACHINEVERSION / $MACHINEARCH" \
#         && curl -jSLN \
#             -o /usr/local/bin/docker-machine \
#             https://github.com/docker/machine/releases/download/v${MACHINEVERSION}/docker-machine-${MACHINEARCH} \
#         && chmod a+rx /usr/local/bin/docker-machine; \
#     fi \
#
    && rm -rf /tmp/* /var/cache/apk/*
#
COPY root/ /
#
# VOLUME /home/${S6_USER:-alpine}/
# VOLUME /home/${S6_USER:-alpine}/project/ # specify at runtime
#
# WORKDIR /home/${S6_USER:-alpine}/project/
#
ENTRYPOINT ["/usershell"]
CMD ["docker", "--version"]
