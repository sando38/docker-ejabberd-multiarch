FROM docker.io/debian:bullseye as builder

ARG EJABBERD_TAG=21.12
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US \
    LC_ALL=en_US.UTF-8 \
    PATH_EJABBERD_HOME=/home/ejabberd \
    DEBIAN_FRONTEND=noninteractive

RUN set -x \
    && addgroup --gid 999 ejabberd \
    && adduser --uid 999 --gid 999 --disabled-password --gecos "" --home $PATH_EJABBERD_HOME ejabberd \
    && apt-get update \
    && apt-get install -y automake \
        build-essential \
        dirmngr \
        erlang-src erlang-dev \
        git \
        gpg \
        libexpat-dev \
        libgd-dev \
        libssl-dev \
        libsqlite3-dev \
        libwebp-dev \
        libyaml-dev \
        wget \
        zlib1g-dev \
        ca-certificates \
        erlang-snmp erlang-ssl erlang-ssh \
        erlang-tools erlang-xmerl erlang-diameter erlang-eldap \
        erlang-eunit erlang-odbc erlang-os-mon \
        erlang-parsetools erlang-inets \
        gsfonts \
        imagemagick \
        inotify-tools \
        ldnsutils \
        libgd3 \
        libwebp6 \
        libyaml-0-2 \
        locales \
        openssl \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && wget https://s3.amazonaws.com/rebar3/rebar3 \
    && chmod +x rebar3 \
    && git clone https://github.com/processone/ejabberd.git --branch $EJABBERD_TAG --single-branch --depth=1 ejabberd \
    && cd ejabberd \
    && ./autogen.sh \
    && ./configure --with-rebar=/rebar3 \
      --enable-user=ejabberd \
      --enable-group=ejabberd \
      --enable-full-xml \
  #    --enable-latest-deps \
      --enable-mssql \
      --enable-mysql \
      --enable-new-sql-schema \
      --enable-odbc \
      --disable-pam \
      --enable-pgsql \
      --enable-redis \
      --enable-roster-gateway-workaround \
      --enable-sip \
      --enable-sqlite \
      --enable-stun \
      --disable-tools \
      --disable-zlib \
    && make rel \
    && cp _build/prod/rel/ejabberd/ejabberd-*.tar.gz $PATH_EJABBERD_HOME

COPY rootfs /

FROM docker.io/debian:bullseye-slim as ejabberd

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US \
    LC_ALL=en_US.UTF-8 \
    PATH_EJABBERD_HOME=/home/ejabberd \
    PATH_FILESERVER=/home/ejabberd/files \
    PATH_MODULE_CONFIG=/home/ejabberd/etc/ejabberd/config-modules \
    PATH_STARTUP_SCRIPTS=/home/ejabberd/startup-scripts \
    PATH_TLS_CERTIFICATES=/home/ejabberd/tls \
    PATH_UPLOAD=/home/ejabberd/upload

COPY --from=builder $PATH_EJABBERD_HOME $PATH_EJABBERD_HOME

RUN set -x \
  && addgroup --gid 999 ejabberd \
  && adduser --uid 999 --gid 999 --disabled-password --gecos "" --home $PATH_EJABBERD_HOME ejabberd \
  && apt-get update \
  && apt-get install -y --no-install-recommends --fix-missing \
      ca-certificates \
      dnsutils \
      gsfonts \
#      imagemagick \
      inotify-tools \
      ldnsutils \
      libgd3 \
      libwebp6 \
      libyaml-0-2 \
      locales \
      openssl \
  && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
  && locale-gen \
  && tar -xzf $PATH_EJABBERD_HOME/ejabberd-*.tar.gz -C $PATH_EJABBERD_HOME \
  && rm -rf $PATH_EJABBERD_HOME/ejabberd-*.tar.gz \
  && chown -R 999:999 $PATH_EJABBERD_HOME \
  && chmod 555 $PATH_STARTUP_SCRIPTS/* $PATH_EJABBERD_HOME/bin/* \
  && mv $PATH_EJABBERD_HOME/etc/ejabberd/ejabberd.yml $PATH_EJABBERD_HOME/etc/ejabberd/ejabberd.yml.template \
  && ln -s $PATH_EJABBERD_HOME/bin/ejabberdctl /usr/bin/ejabberdctl

USER ejabberd

WORKDIR $PATH_EJABBERD_HOME

EXPOSE 4369 5222 5223 5269 5270 5280 5443

VOLUME $PATH_EJABBERD_HOME/etc/ejabberd $PATH_FILESERVER $PATH_TLS_CERTIFICATES $PATH_UPLOAD

LABEL org.opencontainers.image.description="ejabberd image, built for multiple architectures and with startup configuration script" \
      org.opencontainers.image.version="${EJABBERD_TAG}" \
      org.opencontainers.image.authors="Sando <sandomir@tutanota.com.com>" \
      org.opencontainers.image.source="https://github.com/sando38/docker-ejabberd-multiarch"

CMD ["startup-scripts/run.sh"]
