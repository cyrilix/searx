FROM alpine:3.10
ENTRYPOINT ["/sbin/tini","--","/usr/local/searx/dockerfiles/docker-entrypoint.sh"]
EXPOSE 8080
VOLUME /etc/searx
VOLUME /var/log/uwsgi

ARG SEARX_GIT_VERSION="v0.16.0"

ARG SEARX_GID=977
ARG SEARX_UID=977

RUN addgroup -g ${SEARX_GID} searx && \
    adduser -u ${SEARX_UID} -D -h /usr/local/searx -s /bin/sh -G searx searx

ARG TIMESTAMP_SETTINGS=0
ARG TIMESTAMP_UWSGI=0

ENV INSTANCE_NAME=searx \
    AUTOCOMPLETE="" \
    BASE_URL="" \
    MORTY_KEY="" \
    MORTY_URL=""

RUN apk upgrade --no-cache && apk add git
USER searx
RUN git clone https://github.com/searx/searx.git /usr/local/searx

WORKDIR /usr/local/searx
RUN git checkout ${SEARX_GIT_VERSION}

USER 0
RUN apk add --no-cache -t build-dependencies \
    build-base \
    py3-setuptools \
    python3-dev \
    libffi-dev \
    libxslt-dev \
    libxml2-dev \
    openssl-dev \
    tar \
    git \
 && apk add --no-cache \
    ca-certificates \
    su-exec \
    python3 \
    libxml2 \
    libxslt \
    openssl \
    tini \
    uwsgi \
    uwsgi-python3 \
 && pip3 install --upgrade pip \
 && pip3 install --no-cache -r requirements.txt \
 && apk del build-dependencies

COPY --chown=searx:searx . .

USER searx
RUN /usr/bin/python3 -m compileall -q searx \
    echo "VERSION_STRING = VERSION_STRING + \"-$(git describe --tags)\"" >> /usr/local/searx/searx/version.py;


# Keep this argument at the end since it change each time
LABEL maintainer="Cyrille Nofficial <https://github.com/cyrilix/docker>" \
      description="A privacy-respecting, hackable metasearch engine." \
      org.label-schema.version="${SEARX_GIT_VERSION}" \
      org.label-schema.url="${LABEL_VCS_URL}" \
      org.label-schema.usage="https://github.com/searx/searx-docker"
