FROM alpine:3.15.4 AS build
ARG VERSION=master

RUN apk upgrade --update musl \
    && apk add \
    autoconf \
    automake \
    bash \
    build-base \
    curl \
    elixir \
    erlang-odbc \
    erlang-reltool \
    expat-dev \
    file \
    gd-dev \
    git \
    jpeg-dev \
    libpng-dev \
    libwebp-dev \
    linux-pam-dev \
    openssl \
    openssl-dev \
    sqlite-dev \
    yaml-dev \
    zlib-dev

RUN mix local.hex --force \
    && mix local.rebar --force

WORKDIR ejabberd

RUN git clone https://github.com/processone/ejabberd.git . \
    && git checkout $VERSION \
    && mv .github/container/ejabberdctl.template . \
    && ./autogen.sh \
    && ./configure --with-rebar=mix --enable-all \
    && mix deps.get \
    && make rel

RUN cp -r _build/prod/rel/ejabberd/ /opt/ejabberd-$VERSION \
    && mkdir -p /opt/ejabberd \
    && mv /opt/ejabberd-$VERSION/conf /opt/ejabberd/conf

RUN BINPATH=$(dirname $(find /opt -name msgs))/bin/ \
    && mkdir $BINPATH \
    && cp tools/captcha*.sh $BINPATH

RUN export PEM=/opt/ejabberd/conf/server.pem \
    && curl -o "/opt/ejabberd/conf/cacert.pem" 'https://curl.se/ca/cacert.pem' \
    && openssl req -x509 \
            -batch \
            -nodes \
            -newkey rsa:4096 \
            -keyout $PEM \
            -out $PEM \
            -days 3650 \
            -subj "/CN=localhost" \
    && sed -i '/^loglevel:/a \ \
        \nca_file: /opt/ejabberd/conf/cacert.pem \
        \ncertfiles: \
        \n  - /opt/ejabberd/conf/server.pem' "/opt/ejabberd/conf/ejabberd.yml"

COPY rootfs /

FROM alpine:3.15.4
ENV HOME=/opt/ejabberd

COPY --from=build /opt /opt

# add packages and remove cache
RUN apk upgrade --update musl \
    && apk add \
    expat \
    freetds \
    gd \
    jpeg \
    libgd \
    libpng \
    libstdc++ \
    libwebp \
    linux-pam \
    ncurses-libs \
    openssl \
    sqlite \
    sqlite-libs \
    unixodbc \
    yaml \
    zlib \
    && ln -fs /usr/lib/libtdsodbc.so.0 /usr/lib/libtdsodbc.so \
    && rm -rf /var/cache/apk/* \
# user and directories
    && addgroup ejabberd -g 9000 \
    && adduser -s /bin/sh -D -G ejabberd ejabberd -u 9000 \
    && mkdir -p $HOME/conf $HOME/database $HOME/logs $HOME/upload $HOME/files $HOME/tls $HOME/.ejabberd-modules \
# ejabberdctl link, scripts and configuration files
    && mv $HOME/scripts/* /usr/local/bin \
    && echo -e \
         "#!/bin/sh \
        \n[ -z \$ERLANG_NODE_ARG ] && export ERLANG_NODE_ARG=ejabberd@localhost \
        \nexport CONFIG_DIR=/opt/ejabberd/conf \
        \nexport LOGS_DIR=/opt/ejabberd/logs \
        \nexport SPOOL_DIR=/opt/ejabberd/database \
        \nexec $(find /opt -name ejabberdctl) \"\$@\"" > $HOME/scripts/ejabberdctl \
    && chmod +x /usr/local/bin/* /opt/ejabberd/scripts/* \
    && mv $HOME/conf/ejabberd.yml $HOME/conf/ejabberd.yml.template \
    && chown -R ejabberd:ejabberd $HOME

HEALTHCHECK \
    --interval=5s \
    --timeout=5s \
    --start-period=5s \
    --retries=120 \
    CMD /opt/ejabberd/scripts/ejabberdctl status

WORKDIR $HOME
USER ejabberd
VOLUME ["$HOME/conf", "$HOME/database", "$HOME/logs", "$HOME/upload", "$HOME/files", "$HOME/tls", "$HOME/.ejabberd-modules"]
EXPOSE 1883 4369-4399 5222 5269 5280 5443

CMD ["/usr/local/bin/run.sh"]
