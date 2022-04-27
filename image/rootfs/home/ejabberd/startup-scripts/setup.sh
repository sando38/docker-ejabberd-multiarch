#!/bin/sh
#set -x
# Create ejabberd configuration file
CONFIGPATH=$PATH_EJABBERD_HOME/etc/ejabberd
CONFIGFILE=$CONFIGPATH/ejabberd.yml
echo ">>> ======================================================================="
echo ">>>          Start generating ejabberd.yml configuration file"
echo ">>> ======================================================================="
echo ">>> Setting virtual hosts, logging parameters, default language"
echo ">>> "
# virtual hosts
cat > $CONFIGFILE <<EOF;
###
###              ejabberd configuration file
###
### The parameters used in this configuration file are explained at
###
###       https://docs.ejabberd.im/admin/configuration
###
### The configuration file is written in YAML.
### *******************************************************
### *******           !!! WARNING !!!               *******
### *******     YAML IS INDENTATION SENSITIVE       *******
### ******* MAKE SURE YOU INDENT SECTIONS CORRECTLY *******
### *******************************************************
### Refer to http://en.wikipedia.org/wiki/YAML for the brief description.
###
hosts:
  - ${XMPP_DOMAIN0:-localhost}
EOF
if [ ! -z $XMPP_DOMAIN1 ]; then
cat >> $CONFIGFILE <<EOF;
  - $XMPP_DOMAIN1
EOF
fi
if [ ! -z $XMPP_DOMAIN2 ]; then
cat >> $CONFIGFILE <<EOF;
  - $XMPP_DOMAIN2
EOF
fi
if [ ! -z $XMPP_DOMAIN3 ]; then
cat >> $CONFIGFILE <<EOF;
  - $XMPP_DOMAIN3
EOF
fi

# general parameters
cat >> $CONFIGFILE <<EOF;

###.  =================
###'  LOGGING

loglevel: ${LOGLEVEL:-info} # none | emergency | alert | critical | error | warning | notice | info | debug
log_rotate_size: 10485760
log_rotate_count: 1
hide_sensitive_log_data: ${HIDE_SENSITIVE_LOG_DATA:-false}

###.  =================
###'  LANGUAGE

language: ${LANGUAGE_DEFAULT:-en}

###.  =================
###'  ACME-CLIENT

acme:
EOF

if [ "${LISTENER_HTTP_ENABLED:-false}" = true ] || [ "${LISTENER_HTTP_ACME_ENABLED:-true}" = true ]; then
  cat >> $CONFIGFILE <<EOF;
  auto: ${ACME_ENABLED:-true}
EOF
else
  cat >> $CONFIGFILE <<EOF;
  auto: false
EOF
fi
echo ">>> Setting ACME client parameters"
cat >> $CONFIGFILE <<EOF;
  contact: "mailto:${ACME_EMAIL:-name@example.com}"
  ca_url: "${ACME_URL:-https://acme-v02.api.letsencrypt.org/directory}"
  cert_type: ${ACME_CERT_TYPE:-rsa} # cert_type: rsa | ec

###.  =================
###'  TLS configuration

EOF
echo ">>> "
echo ">>> ======================================================================="
echo ">>> Setting TLS configuration parameters"
echo ">>> "
if ([ ! -z $TLS_KEY_FILE_XMPP_DOMAIN0 ] || [ ! -z $TLS_CRT_FILE_XMPP_DOMAIN0 ]) || ([ ! -z $TLS_KEY_FILE_XMPP_DOMAIN1 ] || [ ! -z $TLS_CRT_FILE_XMPP_DOMAIN1 ]) || ([ ! -z $TLS_KEY_FILE_XMPP_DOMAIN2 ] || [ ! -z $TLS_CRT_FILE_XMPP_DOMAIN2 ]); then
  cat >> $CONFIGFILE <<EOF;
certfiles:
EOF
fi
if ([ ! -z $TLS_KEY_FILE_XMPP_DOMAIN0 ] || [ ! -z $TLS_CRT_FILE_XMPP_DOMAIN0 ]); then
  cat >> $CONFIGFILE <<EOF;
  - ${PATH_TLS_CERTIFICATES:-$PATH_EJABBERD_HOME/tls}/${TLS_KEY_FILE_XMPP_DOMAIN0:-privkey.pem}
  - ${PATH_TLS_CERTIFICATES:-$PATH_EJABBERD_HOME/tls}/${TLS_CRT_FILE_XMPP_DOMAIN0:-fullchain.pem}
EOF
fi
if ([ ! -z $TLS_KEY_FILE_XMPP_DOMAIN1 ] || [ ! -z $TLS_CRT_FILE_XMPP_DOMAIN1 ]); then
  cat >> $CONFIGFILE <<EOF;
  - ${PATH_TLS_CERTIFICATES:-$PATH_EJABBERD_HOME/tls}/${TLS_KEY_FILE_XMPP_DOMAIN1:-privkey.pem}
  - ${PATH_TLS_CERTIFICATES:-$PATH_EJABBERD_HOME/tls}/${TLS_CRT_FILE_XMPP_DOMAIN1:-fullchain.pem}
EOF
fi
if ([ ! -z $TLS_KEY_FILE_XMPP_DOMAIN2 ] || [ ! -z $TLS_CRT_FILE_XMPP_DOMAIN2 ]); then
  cat >> $CONFIGFILE <<EOF;
  - ${PATH_TLS_CERTIFICATES:-$PATH_EJABBERD_HOME/tls}/${TLS_KEY_FILE_XMPP_DOMAIN2:-privkey.pem}
  - ${PATH_TLS_CERTIFICATES:-$PATH_EJABBERD_HOME/tls}/${TLS_CRT_FILE_XMPP_DOMAIN2:-fullchain.pem}
EOF
fi
## Generating DH PARAM file
echo ">>> ======================================================================="
echo ">>> ###' Checking DH PARAM file existence at ${PATH_TLS_CERTIFICATES:-$PATH_EJABBERD_HOME/tls}/${DHPARAM_FILE_NAME:-dh.pem}"
echo ">>> "
if [ -f "${PATH_TLS_CERTIFICATES:-$PATH_EJABBERD_HOME/tls}/${DHPARAM_FILE_NAME:-dh.pem}" ]; then
  echo ">>> dhparam file exists, using existing file"
  echo ">>> "
else
  echo ">>> generating dh param file with keysize ${DHPARAM_KEYSIZE:-2048}"
  echo ">>> "
  openssl dhparam -out ${PATH_TLS_CERTIFICATES:-$PATH_EJABBERD_HOME/tls}/${DHPARAM_FILE_NAME:-dh.pem} ${DHPARAM_KEYSIZE:-2048}
fi
cat >> $CONFIGFILE <<EOF;

define_macro:
  'TLS_CIPHERS': "${TLS_CIPHERS:-ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256}"
  'TLS_OPTIONS':
EOF
if [ "${TLS_PROTOCOL_SSL_V3_DISABLED:-true}" = true ]; then
  cat >> $CONFIGFILE <<EOF;
    - "no_sslv3"
EOF
fi
if [ "${TLS_PROTOCOL_TLS_V1_DISABLED:-true}" = true ]; then
  cat >> $CONFIGFILE <<EOF;
    - "no_tlsv1"
EOF
fi
if [ "${TLS_PROTOCOL_TLS_V1_1_DISABLED:-true}" = true ]; then
  cat >> $CONFIGFILE <<EOF;
    - "no_tlsv1_1"
EOF
fi
if [ "${TLS_PROTOCOL_TLS_V1_2_DISABLED:-false}" = true ]; then
  cat >> $CONFIGFILE <<EOF;
    - "no_tlsv1_2"
EOF
fi
cat >> $CONFIGFILE <<EOF;
    - "cipher_server_preference"
    - "no_compression"
  'DHFILE': "${PATH_TLS_CERTIFICATES:-$PATH_EJABBERD_HOME/tls}/${DHPARAM_FILE_NAME:-dh.pem}"

c2s_ciphers: 'TLS_CIPHERS'
c2s_protocol_options: 'TLS_OPTIONS'
EOF
#
### S2S TLS configuration #############################################
#
echo ">>> ======================================================================="
echo ">>> Setting S2S overall configuration parameters"
echo ">>> "

if [ "${LISTENER_S2S_LEGACY_TLS_ENABLED:-false}" = true ] || [ "${LISTENER_S2S_ENABLED:-false}" = true ]; then
cat >> $CONFIGFILE <<EOF;

###.  ==================
###'  S2S GLOBAL OPTIONS

s2s_timeout: ${S2S_TIMEOUT:-60} # in minutes
s2s_ciphers: 'TLS_CIPHERS'
s2s_protocol_options: 'TLS_OPTIONS'
s2s_dhfile: 'DHFILE'
EOF
fi
if [ "${LISTENER_S2S_ENABLED:-false}" = true ]; then
cat >> $CONFIGFILE <<EOF;
s2s_use_starttls: ${LISTENER_S2S_USE_STARTTLS:-false}
EOF
fi
echo ">>> ======================================================================="
echo ">>> Define authentication method"
echo ">>> "
echo ">>> Using auth_method: ${AUTH_METHOD:-mnesia}"
echo ">>> "
cat >> $CONFIGFILE <<EOF;

###.  =================
###'  AUTHENTICATION

auth_method: ${AUTH_METHOD:-mnesia}
auth_password_format: ${AUTH_PASSWORD_FORMAT:-scram}
EOF
if [ "${AUTH_PASSWORD_FORMAT:-scram}" = scram ]; then
  cat >> $CONFIGFILE <<EOF;
auth_scram_hash: ${AUTH_SCRAM_HASH:-sha256}
EOF
fi

if [ "$AUTH_METHOD" = ldap ]; then
  echo ">>> ======================================================================="
  echo ">>> Configure LDAP backend"
  echo ">>> "
  cat >> $CONFIGFILE <<EOF;

###.  =================
###'  LDAP AUTHENTICATION

include_config_file:
  - $CONFIGPATH/ldap.yml

EOF

cat > $CONFIGPATH/ldap.yml <<EOF;
# bind account & credentials
ldap_rootdn: "$LDAP_BIND_DN"
ldap_password: "$LDAP_BIND_PW"
# user base, attributes and filter
ldap_base: "$LDAP_USER_BASE_DN"
EOF
if [ ! -z $LDAP_UID ] || [ ! -z $LDAP_UID_ALTERNATIVE ] || [ ! -z $LDAP_UID_ALTERNATIVE_2 ]; then
  cat >> $CONFIGPATH/ldap.yml <<EOF;
ldap_uids:
EOF
fi
if [ ! -z $LDAP_UID ]; then
  cat >> $CONFIGPATH/ldap.yml <<EOF;
  - $LDAP_UID # default is '%u'
EOF
fi
if [ ! -z $LDAP_UID_ALTERNATIVE ]; then
  cat >> $CONFIGPATH/ldap.yml <<EOF;
  - $LDAP_UID_ALTERNATIVE # default is '%u'
EOF
fi
if [ ! -z $LDAP_UID_ALTERNATIVE_2 ]; then
  cat >> $CONFIGPATH/ldap.yml <<EOF;
  - $LDAP_UID_ALTERNATIVE_2 # default is '%u'
EOF
fi
cat >> $CONFIGPATH/ldap.yml <<EOF;
ldap_deref_aliases: ${LDAP_DEREF_ALIASES:-never} # defaults to 'never'
ldap_filter: "${LDAP_USER_FILTER:-(objectClass=inetOrgPerson)}" # no default, NOTE: uid attribute must not be included since it will be appended automatically
EOF
#if [ ! -z $LDAP_DN_FILTER ]; then
#  cat >> $CONFIGPATH/ldap.yml <<EOF;
#ldap_dn_filter: "$LDAP_DN_FILTER" # no default, because it performs another (potential unnecessary) ldap lookup
#EOF
#fi
cat >> $CONFIGPATH/ldap.yml <<EOF;
# tls settings
ldap_encrypt: ${LDAP_ENCRYPT:-none}
EOF
if [ ! "$LDAP_ENCRYPT" = tls ]; then
  cat >> $CONFIGPATH/ldap.yml <<EOF;
ldap_tls_verify: false
EOF
else
  cat >> $CONFIGPATH/ldap.yml <<EOF;
ldap_tls_verify: ${LDAP_TLS_VERIFY:-false}
EOF
fi
if [ "$LDAP_ENCRYPT" = tls ] && ([ "$LDAP_TLS_VERIFY" = soft ] || [ "$LDAP_TLS_VERIFY" = hard ]); then
  cat >> $CONFIGPATH/ldap.yml <<EOF;
ldap_tls_depth: ${LDAP_TLS_VERIFY_DEPTH:-1} # defaults to '1'
ldap_tls_cacertfile: ${PATH_TLS_CERTIFICATES:-$PATH_EJABBERD_HOME/tls}/${LDAP_TLS_CA_CRT_FILE_NAME:-ca.pem}
ldap_tls_certfile: ${PATH_TLS_CERTIFICATES:-$PATH_EJABBERD_HOME/tls}/${LDAP_TLS_CRT_FILE_NAME:-server.pem}
EOF
fi
if [ ! -z $LDAP_SERVER_1 ] || [ ! -z $LDAP_SERVER_2 ] || [ ! -z $LDAP_SERVER_3 ]; then
  cat >> $CONFIGPATH/ldap.yml <<EOF;
# ldap hosts address, ports and backup server
ldap_servers: # list of ldap servers
EOF
elif [ -z $LDAP_SERVER_1 ] || [ -z $LDAP_SERVER_2 ] || [ -z $LDAP_SERVER_3 ]; then
  cat >> $CONFIGPATH/ldap.yml <<EOF;
# ldap host addresses, ports and backup server
ldap_servers:
  - localhost
EOF
fi
if [ ! -z $LDAP_SERVER_1 ]; then
  cat >> $CONFIGPATH/ldap.yml <<EOF;
  - $LDAP_SERVER_1
EOF
fi
if [ ! -z $LDAP_SERVER_2 ]; then
cat >> $CONFIGPATH/ldap.yml <<EOF;
  - $LDAP_SERVER_2
EOF
fi
if [ ! -z $LDAP_SERVER_3 ]; then
cat >> $CONFIGPATH/ldap.yml <<EOF;
  - $LDAP_SERVER_3
EOF
fi
if [ ! -z $LDAP_PORT ]; then
  cat >> $CONFIGPATH/ldap.yml <<EOF;
ldap_port: $LDAP_PORT # default depends if tls '636' or not '389'
EOF
elif [ "$LDAP_ENCRYPT" = tls ]; then
  cat >> $CONFIGPATH/ldap.yml <<EOF;
ldap_port: 636 # default depends if tls '636' or not '389'
EOF
else
  cat >> $CONFIGPATH/ldap.yml <<EOF;
ldap_port: 389 # default depends if tls '636' or not '389'
EOF
fi
if [ ! -z $LDAP_BACKUP_SERVER_1 ] || [ ! -z $LDAP_BACKUP_SERVER_2 ] || [ ! -z $LDAP_BACKUP_SERVER_3 ]; then
  cat >> $CONFIGPATH/ldap.yml <<EOF;
ldap_backups:  # list of backup servers for all servers listed in ldap_servers
EOF
fi
if [ ! -z $LDAP_BACKUP_SERVER_1 ]; then
  cat >> $CONFIGPATH/ldap.yml <<EOF;
  - $LDAP_BACKUP_SERVER_1 # list of backup servers for all servers listed in ldap_servers
EOF
fi
if [ ! -z $LDAP_BACKUP_SERVER_2 ]; then
  cat >> $CONFIGPATH/ldap.yml <<EOF;
  - $LDAP_BACKUP_SERVER_2
EOF
fi
if [ ! -z $LDAP_BACKUP_SERVER_3 ]; then
  cat >> $CONFIGPATH/ldap.yml <<EOF;
  - $LDAP_BACKUP_SERVER_3 # list of backup servers for all servers listed in ldap_servers
EOF
fi
fi
echo ">>> ======================================================================="
echo ">>> Configure ejabberd listeners"
echo ">>> "
cat >> $CONFIGFILE <<EOF;

###.  ===============
###'  LISTENING PORTS

include_config_file:
  - $CONFIGPATH/c2s.yml
EOF
echo ">>> Configure ejabberd c2s listener"
cat >> $CONFIGPATH/c2s.yml <<EOF;
listen:
  -
    port: ${LISTENER_C2S_PORT:-5222}
    ip: "${LISTENER_C2S_IP:-::}"
    module: ejabberd_c2s
    max_stanza_size: 262144
    dhfile: 'DHFILE'
    shaper: c2s_shaper
    access: c2s
    starttls: ${LISTENER_C2S_STARTTLS:-false}
    starttls_required: ${LISTENER_C2S_STARTTLS_REQUIRED:-false}
    use_proxy_protocol: ${LISTENER_C2S_PROXY_PROTOCOL:-false}
EOF

if [ "${LISTENER_C2S_LEGACY_TLS_ENABLED:-false}" = true ]; then
  echo ">>> Configure ejabberd c2s TLS listener"
  cat >> $CONFIGFILE <<EOF;
  - $CONFIGPATH/c2s-tls.yml
EOF
cat > $CONFIGPATH/c2s-tls.yml <<EOF
listen:
  -
    port: ${LISTENER_C2S_LEGACY_TLS_PORT:-5223}
    ip: "${LISTENER_C2S_LEGACY_TLS_IP:-::}"
    module: ejabberd_c2s
    max_stanza_size: 262144
    tls: true
    dhfile: 'DHFILE'
    shaper: c2s_shaper
    access: c2s
    use_proxy_protocol: ${LISTENER_C2S_LEGACY_TLS_PROXY_PROTOCOL:-false}
EOF
fi

if [ "${LISTENER_S2S_ENABLED:-false}" = true ]; then
  echo ">>> Configure ejabberd s2s listener"
  cat >> $CONFIGFILE <<EOF;
  - $CONFIGPATH/s2s.yml
EOF
cat > $CONFIGPATH/s2s.yml <<EOF
listen:
  -
    port: ${LISTENER_S2S_PORT:-5269}
    ip: "${LISTENER_S2S_IP:-::}"
    module: ejabberd_s2s_in
    max_stanza_size: 524288
    use_proxy_protocol: ${LISTENER_S2S_PROXY_PROTOCOL:-false}
EOF
fi

if [ "${LISTENER_S2S_LEGACY_TLS_ENABLED:-false}" = true ]; then
  echo ">>> Configure ejabberd s2s TLS listener"
  cat >> $CONFIGFILE <<EOF;
  - $CONFIGPATH/s2s-tls.yml
EOF
cat > $CONFIGPATH/s2s-tls.yml <<EOF
listen:
  -
    port: ${LISTENER_S2S_LEGACY_TLS_PORT:-5270}
    ip: "${LISTENER_S2S_LEGACY_TLS_IP:-::}"
    module: ejabberd_s2s_in
    max_stanza_size: 524288
    tls: true
    use_proxy_protocol: ${LISTENER_S2S_LEGACY_TLS_PROXY_PROTOCOL:-false}
EOF
fi

if [ "${LISTENER_STUNTURN_TCP_ENABLED:-false}" = true ]; then
  echo ">>> Configure ejabberd STUN/TURN TCP listener"
  cat >> $CONFIGFILE <<EOF;
  - $CONFIGPATH/stun-turn-tcp.yml
EOF
cat > $CONFIGPATH/stun-turn-tcp.yml <<EOF
listen:
  -
    port: ${LISTENER_STUNTURN_TCP_PORT:-3478}
    ip: "${LISTENER_STUNTURN_TCP_IP:-::}"
    transport: tcp
    use_turn: ${LISTENER_STUNTURN_TCP_USE_TURN:-false}
    turn_ipv4_address: ${LISTENER_STUNTURN_TCP_TURN_IP4:-10.20.30.40}
    turn_min_port: ${LISTENER_STUNTURN_TCP_TURN_MIN_PORT:-49152} # default '49152'
    turn_max_port: ${LISTENER_STUNTURN_TCP_TURN_MAX_PORT:-65535} # default '65535'
    module: ejabberd_stun
    # use_proxy_protocol: ${LISTENER_STUNTURN_TCP_PROXY_PROTOCOL:-false}
EOF
fi

if [ "${LISTENER_STUNTURN_UDP_ENABLED:-false}" = true ]; then
  echo ">>> Configure ejabberd STUN/TURN UDP listener"
  cat >> $CONFIGFILE <<EOF;
  - $CONFIGPATH/stun-turn-udp.yml
EOF
cat > $CONFIGPATH/stun-turn-udp.yml <<EOF
listen:
  -
    port: ${LISTENER_STUNTURN_UDP_PORT:-3478}
    ip: "${LISTENER_STUNTURN_UDP_IP:-::}"
    transport: udp
    use_turn: ${LISTENER_STUNTURN_UDP_USE_TURN:-false}
    turn_ipv4_address: ${LISTENER_STUNTURN_UDP_TURN_IP4:-10.20.30.40}
    turn_min_port: ${LISTENER_STUNTURN_UDP_TURN_MIN_PORT:-49152} # default '49152'
    turn_max_port: ${LISTENER_STUNTURN_UDP_TURN_MAX_PORT:-65535} # default '65535'
    module: ejabberd_stun
    # use_proxy_protocol: ${LISTENER_STUNTURN_UDP_PROXY_PROTOCOL:-false}
EOF
fi

if [ "${LISTENER_STUNSTURNS_TLS_ENABLED:-false}" = true ]; then
  echo ">>> Configure ejabberd STUNS/TURNS listener"
  cat >> $CONFIGFILE <<EOF;
  - $CONFIGPATH/stuns-turns.yml
EOF
cat > $CONFIGPATH/stuns-turns.yml <<EOF
listen:
  -
    port: ${LISTENER_STUNSTURNS_TLS_PORT:-5349}
    ip: "${LISTENER_STUNSTURNS_TLS_IP:-::}"
    transport: tcp
    tls: true
    use_turn: ${LISTENER_STUNSTURNS_TLS_USE_TURN:-false}
    turn_ipv4_address: ${LISTENER_STUNSTURNS_TLS_TURN_IP4:-10.20.30.40}
    turn_min_port: ${LISTENER_STUNSTURNS_TLS_TURN_MIN_PORT:-49152} # default '49152'
    turn_max_port: ${LISTENER_STUNSTURNS_TLS_TURN_MAX_PORT:-65535} # default '65535'
    module: ejabberd_stun
    # use_proxy_protocol: ${LISTENER_STUNSTURNS_TLS_PROXY_PROTOCOL:-false}
EOF
fi

if [ "${LISTENER_HTTP_ENABLED:-false}" = true ]; then
  echo ">>> Configure ejabberd HTTP listener"
  cat >> $CONFIGFILE <<EOF;
  - $CONFIGPATH/http.yml
EOF
cat > $CONFIGPATH/http.yml <<EOF
listen:
  -
    port: ${LISTENER_HTTP_PORT:-5280}
    ip: "${LISTENER_HTTP_IP:-::}"
    module: ejabberd_http
    tls: false
    use_proxy_protocol: ${LISTENER_HTTP_PROXY_PROTOCOL:-false}
    request_handlers:
EOF
fi
# configure admin interface
if [ "${LISTENER_HTTP_ENABLED:-false}" = true ] || [ "${LISTENER_HTTP_ADMIN_ENABLED:-false}" = true ]; then
  echo ">>> Configure ejabberd HTTPS listener"
  cat >> $CONFIGPATH/http.yml <<EOF
      "/admin": ejabberd_web_admin
EOF
fi
# configure ACME
if [ "${LISTENER_HTTP_ENABLED:-false}" = true ] || [ "${LISTENER_HTTP_ACME_ENABLED:-true}" = true ]; then
cat >> $CONFIGPATH/http.yml <<EOF
      "/.well-known/acme-challenge": ejabberd_acme
EOF
fi

if [ "${LISTENER_HTTPS_ENABLED:-true}" = true ]; then
cat >> $CONFIGFILE <<EOF;
  - $CONFIGPATH/https.yml
EOF
cat > $CONFIGPATH/https.yml <<EOF
listen:
  -
    port: ${LISTENER_HTTPS_PORT:-5443}
    ip: "${LISTENER_HTTPS_IP:-::}"
    module: ejabberd_http
    tls: true
    dhfile: 'DHFILE'
    ciphers: 'TLS_CIPHERS'
    protocol_options: 'TLS_OPTIONS'
    use_proxy_protocol: ${LISTENER_HTTPS_PROXY_PROTOCOL:-false}
    request_handlers:
EOF
fi

# configure admin interface
if [ "${LISTENER_HTTPS_ENABLED:-true}" = true ] || [ "${LISTENER_HTTPS_ADMIN_ENABLED:-true}" = true ]; then
cat >> $CONFIGPATH/https.yml <<EOF
      "/admin": ejabberd_web_admin
EOF
fi
# configure api
if [ "${LISTENER_HTTPS_ENABLED:-true}" = true ] || [ "${LISTENER_HTTPS_API_ENABLED:-false}" = true ]; then
cat >> $CONFIGPATH/https.yml <<EOF
      "/api": mod_http_api
EOF
fi
# configure bosh
if [ "${LISTENER_HTTPS_ENABLED:-true}" = true ] || [ "${LISTENER_HTTPS_BOSH_ENABLED:-true}" = true ]; then
cat >> $CONFIGPATH/https.yml <<EOF
      "/bosh": mod_bosh
EOF
fi
# configure conversejs
if [ "${LISTENER_HTTPS_ENABLED:-true}" = true ] || [ "${LISTENER_HTTPS_CONVERSEJS_ENABLED:-false}" = true ]; then
cat >> $CONFIGPATH/https.yml <<EOF
      "/conversejs": mod_conversejs
EOF
fi
# configure fileserver
if [ "${LISTENER_HTTPS_ENABLED:-true}" = true ] || [ "${LISTENER_HTTPS_FILESERVER_ENABLED:-false}" = true ]; then
cat >> $CONFIGPATH/https.yml <<EOF
      "/files": mod_http_fileserver
EOF
fi
# configure upload
if [ "${LISTENER_HTTPS_ENABLED:-true}" = true ] || [ "${LISTENER_HTTPS_UPLOAD_ENABLED:-true}" = true ]; then
cat >> $CONFIGPATH/https.yml <<EOF
      "/upload": mod_http_upload
EOF
fi
# configure websocket
if [ "${LISTENER_HTTPS_ENABLED:-true}" = true ] || [ "${LISTENER_HTTPS_WS_ENABLED:-true}" = true ]; then
cat >> $CONFIGPATH/https.yml <<EOF
      "/ws": ejabberd_http_ws
EOF
fi
# configure mqtt
if [ "${LISTENER_MQTT_ENABLED:-false}" = true ]; then
cat >> $CONFIGFILE <<EOF;
  - $CONFIGPATH/mqtt.yml
EOF
cat > $CONFIGPATH/mqtt.yml <<EOF
listen:
  -
    port: ${LISTENER_MQTT_PORT:-1883}
    ip: "${LISTENER_MQTT_IP:-::}"
    tls: ${LISTENER_MQTT_TLS:-false}
    module: mod_mqtt
    backlog: 1000
EOF
fi
cat >> $CONFIGFILE <<EOF;
# additional listeners, e.g. for jitsi video bridge, etc.
EOF
if [ ! -z $ADDITIONAL_LISTENER_1_NAME ] || [ ! -z $ADDITIONAL_LISTENER_2_NAME ] || [ ! -z $ADDITIONAL_LISTENER_3_NAME ]; then
echo ">>> Configure additional listeners"
echo ">>>"
if [ ! -z $ADDITIONAL_LISTENER_1_NAME ]; then
  echo ">>> define $ADDITIONAL_LISTENER_1_NAME"
  cat >> $CONFIGFILE <<EOF;
  - $CONFIGPATH/$ADDITIONAL_LISTENER_1_NAME.yml
EOF
fi
if [ ! -z $ADDITIONAL_LISTENER_2_NAME ]; then
  echo ">>> define $ADDITIONAL_LISTENER_2_NAME"
  cat >> $CONFIGFILE <<EOF;
  - $CONFIGPATH/$ADDITIONAL_LISTENER_2_NAME.yml
EOF
fi
if [ ! -z $ADDITIONAL_LISTENER_3_NAME ]; then
  echo ">>> define $ADDITIONAL_LISTENER_3_NAME"
  cat >> $CONFIGFILE <<EOF;
  - $CONFIGPATH/$ADDITIONAL_LISTENER_3_NAME.yml
EOF
fi
fi
#
### Database configuration #############################################
#
echo ">>> "
echo ">>> ======================================================================="
echo ">>> Configure database setup"
echo ">>> "
echo ">>> use default DB: ${DEFAULT_DB:-mnesia}"
echo ">>> use default RAM DB: ${DEFAULT_RAM_DB:-mnesia}"
echo ">>> "
cat >> $CONFIGFILE <<EOF;

###.  ==============
###'  DATABASE SETUP

default_db: ${DEFAULT_DB:-mnesia}
default_ram_db: ${DEFAULT_RAM_DB:-mnesia}
EOF
if [ ! "${DEFAULT_DB:-mnesia}" = mnesia ] || [ ! -z $DB_TYPE ] || [ "$DEFAULT_RAM_DB" = sql ]; then
  echo ">>> Defining $DB_TYPE backend"
  echo ">>> "
  cat >> $CONFIGFILE <<EOF;
include_config_file:
  - $CONFIGPATH/database.yml
EOF
cat > $CONFIGPATH/database.yml <<EOF;
# generic variables
sql_type: ${DB_TYPE:-sqlite}
sql_server: ${DB_SERVER_ADDRESS:-localhost}
sql_username: ${DB_USER:-ejabberd}
sql_password: ${DB_PASSWORD:-} # default is empty string
sql_database: ${DB_DATABASE_NAME:-ejabberd}
new_sql_schema: ${DB_NEW_SQL_SCHEMA:-false}
sql_queue_type: ${DB_QUEUE_TYPE:-ram}
sql_start_interval: ${DB_START_INTERVAL:-30}
sql_query_timeout: ${DB_QUERY_TIMEOUT:-60}
sql_connect_timeout: ${DB_CONNECTION_TIMEOUT:-5}
# Database non-defaults/ specific settings
EOF
#
### Database non-defaults/ specific settings #############################################
#
  if [ ! -z $DB_SERVER_PORT ]; then
    cat >> $CONFIGPATH/database.yml <<EOF;
sql_port: $DB_SERVER_PORT # default depends on db type, variable is ignored if db type is sqlite
EOF
  fi
  if [ ! -z $DB_PREPARED_STATEMENTS ] && [ "$DB_TYPE" = pgsql ]; then
  cat >> $CONFIGPATH/database.yml <<EOF;
sql_prepared_statements: ${DB_PREPARED_STATEMENTS:-true} # only for type pgsql
EOF
  fi
  if [ ! -z $DB_ODBC_DRIVER ] && [ "$DB_TYPE" = mssql ]; then
    cat >> $CONFIGPATH/database.yml <<EOF;
sql_odbc_driver: ${DB_ODBC_DRIVER:-libtdsodbc.so} # only for type mssql
EOF
  fi
  if [ ! -z $DB_KEEPALIVE_INTERVAL ]; then
    cat >> $CONFIGPATH/database.yml <<EOF;
sql_keepalive_interval: $DB_KEEPALIVE_INTERVAL
EOF
  fi
  if [ ! -z $DB_POOL_SIZE ]; then
    if [ "$DB_TYPE" = sqlite ]; then
      cat >> $CONFIGPATH/database.yml <<EOF;
sql_pool_size: 1 # 1 if db type is sqlite
EOF
    else
      cat >> $CONFIGPATH/database.yml <<EOF;
sql_pool_size: ${DB_POOL_SIZE:-10} # 1 if db type is sqlite
EOF
    fi
  fi
#
### Database SSL/TLS settings #############################################
#
  if [ "$DB_SSL" = true ] && ([ "$DB_TYPE" = pgsql ] || [ "$DB_TYPE" = mysql ]); then
    cat >> $CONFIGPATH/database.yml <<EOF;
# SSL/TLS settings
sql_ssl: $DB_SSL
sql_ssl_verify: ${DB_SSL_VERIFY:-false}
EOF
    if [ "$DB_SSL_VERIFY" = true ]; then
      cat >> $CONFIGPATH/database.yml <<EOF;
sql_ssl_cafile: ${PATH_TLS_CERTIFICATES:-$PATH_EJABBERD_HOME/tls}/$DB_SSL_CAFILE_NAME:-ca.pem}
sql_ssl_certfile: ${PATH_TLS_CERTIFICATES:-$PATH_EJABBERD_HOME/tls}/${DB_SSL_CERTFILE_NAME:-server.pem}
EOF
    fi
  fi
fi
#
### REDIS configuration #############################################
#
if [ "$DEFAULT_RAM_DB" = redis ] || [ "$REDIS_ENABLED" = true ]; then
  echo ">>> ======================================================================="
  echo ">>> Defining $DEFAULT_RAM_DB backend"
  echo ">>> "
  cat >> $CONFIGFILE <<EOF;
  - $CONFIGPATH/redis.yml
EOF
cat > $CONFIGPATH/redis.yml <<EOF;
redis_server: ${REDIS_SERVER_ADDRESS:-localhost}
redis_port: ${REDIS_SERVER_PORT:-6379}
redis_password: ${REDIS_PASSWORD:-}
redis_db: ${REDIS_DB_NUMBER:-0}
redis_pool_size: ${REDIS_POOL_SIZE:-10}
redis_queue_type: ${REDIS_QUEUE_TYPE:-ram}
redis_connect_timeout: ${REDIS_CONNECT_TIMEOUT:-1}
EOF
fi
echo ">>> "
echo ">>> ======================================================================="
echo ">>> Defining access control lists, access rules, API permissions,"
echo ">>> traffic shaper and shaper rules."
echo ">>> "
cat >> $CONFIGFILE <<EOF;

###.   ====================
###'   ACCESS CONTROL LISTS

acl:
  local:
    user_regexp: ""
  loopback:
    ip:
      - 127.0.0.0/8
      - ::1/128
      - ::FFFF:127.0.0.1/128
  admin:
    user:
      - "${JID_ADMIN_USER0:-admin@${XMPP_DOMAIN0:-localhost}}"

disable_sasl_mechanisms:
 - "digest-md5"
 - "x-oauth2"

###.  ============
###'  ACCESS RULES

access_rules:
  local:
    allow: local
  c2s:
    deny: blocked
    allow: all
  announce:
    allow: admin
  configure:
    allow: admin
  muc_create:
    allow: local
  pubsub_createnode:
    allow: local
  trusted_network:
    allow: loopback

## ===============
## API PERMISSIONS
## ===============

api_permissions:
  "console commands":
    from:
      - ejabberd_ctl
    who: all
    what: "*"
  "admin access":
    who:
      access:
        allow:
          acl: loopback
          acl: admin
      oauth:
        scope: "ejabberd:admin"
        access:
          allow:
            acl: loopback
            acl: admin
    what:
      - "*"
      - "!stop"
      - "!start"
  "public commands":
    who:
      ip: 127.0.0.1/8
    what:
      - status
      - connected_users_number

###.  ===============
###'  TRAFFIC SHAPERS

shaper:
  normal:
    rate: 3000
    burst_size: 20000
  fast: 100000

###.  ============
###'  SHAPER RULES

shaper_rules:
  max_user_sessions: 10
  max_user_offline_messages:
    5000: admin
    100: all
  c2s_shaper:
    none: admin
    normal: all
  s2s_shaper: fast

max_fsm_queue: 10000

EOF
#
### modules configuration #############################################
#
echo ">>> ======================================================================="
echo ">>> Configuring ejabberd core modules"
echo ">>> "
cat >> $CONFIGFILE <<EOF;

###.  =======
###'  MODULES

# modules enabled by default in process one ejabberd docker image
include_config_file:
EOF
#
### MOD_ADHOC #############################################
#
if [ "${MOD_ADHOC_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_adhoc.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_adhoc.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_adhoc.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_adhoc.yml <<EOF;
modules:
  mod_adhoc: {}
EOF
  fi
fi
#
### MOD_ADMIN_EXTRA #############################################
#
if [ "${MOD_ADMIN_EXTRA_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_admin_extra.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_admin_extra.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_admin_extra.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_admin_extra.yml <<EOF;
modules:
  mod_admin_extra: {}
EOF
  fi
fi
#
### MOD_ANNOUNCE #############################################
#
if [ "${MOD_ANNOUNCE_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_announce.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_announce.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_announce.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_announce.yml <<EOF;
modules:
  mod_announce:
    access: announce
EOF
  fi
fi
#
### MOD_AVATAR #############################################
#
if [ "${MOD_AVATAR_ENABLED:-true}" = true ] && [ "${MOD_PUBSUB_ENABLED:-true}" = true ] && [ "${MOD_VCARD_ENABLED:-true}" = true ] && [ "${MOD_VCARD_XUPDATE_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_avatar.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_avatar.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_avatar.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_avatar.yml <<EOF;
modules:
  mod_avatar: {}
EOF
  fi
fi
#
### MOD_BLOCKING #############################################
#
if [ "${MOD_BLOCKING_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_blocking.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_blocking.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_blocking.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_blocking.yml <<EOF;
modules:
  mod_blocking: {}
EOF
  fi
fi
#
### MOD_BOSH #############################################
#
if [ "${LISTENER_HTTPS_BOSH_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_bosh.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_bosh.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_bosh.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_bosh.yml <<EOF;
modules:
  mod_bosh: {}
EOF
  fi
fi
#
### MOD_CAPS #############################################
#
if [ "${MOD_CAPS_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_caps.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_caps.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_caps.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_caps.yml <<EOF;
modules:
  mod_caps: {}
EOF
  fi
fi
#
### MOD_CARBONCOPY #############################################
#
if [ "${MOD_CARBONCOPY_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_carboncopy.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_carboncopy.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_carboncopy.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_carboncopy.yml <<EOF;
modules:
  mod_carboncopy: {}
EOF
  fi
fi
#
### MOD_CLIENT_STATE #############################################
#
if [ "${MOD_CLIENT_STATE_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_client_state.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_client_state.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_client_state.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_client_state.yml <<EOF;
modules:
  mod_client_state: {}
EOF
  fi
fi
#
### MOD_CONFIGURE #############################################
#
if [ "${MOD_CONFIGURE_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_configure.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_configure.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_configure.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_configure.yml <<EOF;
modules:
  mod_configure: {}
EOF
  fi
fi
#
### MOD_CONVERSEJS #############################################
#
if [ "${LISTENER_HTTPS_CONVERSEJS_ENABLED:-false}" = true ] && ([ "${LISTENER_HTTPS_BOSH_ENABLED:-true}" = true ] || [ "${LISTENER_HTTPS_WS_ENABLED:-true}" = true ]); then
  echo ">>> creating link to ../mod_conversejs.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_conversejs.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_conversejs.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_conversejs.yml <<EOF;
modules:
  mod_conversejs:
EOF
  if [ "${LISTENER_HTTPS_WS_ENABLED:-true}" = true ]; then
    cat >> $PATH_MODULE_CONFIG/mod_conversejs.yml <<EOF;
    websocket_url: "wss://$XMPP_DOMAIN0:$LISTENER_HTTPS_PORT/ws"
EOF
  else
    cat >> $PATH_MODULE_CONFIG/mod_conversejs.yml <<EOF;
    bosh_service_url: "https://$XMPP_DOMAIN0:$LISTENER_HTTPS_PORT/bosh"
EOF
  fi
  fi
fi
#
### MOD_DISCO #############################################
#
if [ "${MOD_DISCO_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_disco.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_disco.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_disco.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_disco.yml <<EOF;
modules:
  mod_disco: {}
EOF
  fi
fi
#
### MOD_FAIL2BAN #############################################
#
if [ "${MOD_FAIL2BAN_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_fail2ban.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_fail2ban.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_fail2ban.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_fail2ban.yml <<EOF;
modules:
  mod_fail2ban: {}
EOF
  fi
fi
#
### MOD_HTTP_API #############################################
#
if [ "${LISTENER_HTTPS_API_ENABLED:-false}" = true ]; then
  echo ">>> creating link to ../mod_http_api.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_http_api.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_http_api.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_http_api.yml <<EOF;
modules:
  mod_http_api: {}
EOF
  fi
fi
#
### MOD_HTTP_UPLOAD #############################################
#
if [ "${LISTENER_HTTPS_FILESERVER_ENABLED:-false}" = true ]; then
  echo ">>> creating link to ../mod_http_fileserver.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_http_fileserver.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_http_fileserver.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_http_fileserver.yml <<EOF;
modules:
  mod_http_fileserver:
    accesslog: $PATH_EJABBERD_HOME/var/log/ejabberd/access.log # default no access log
    docroot: $PATH_FILESERVER
EOF
  fi
fi
#
### MOD_HTTP_UPLOAD #############################################
#
if [ "${LISTENER_HTTPS_UPLOAD_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_http_upload.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_http_upload.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_http_upload.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_http_upload.yml <<EOF;
modules:
  mod_http_upload:
    put_url: https://@HOST@:${LISTENER_HTTPS_PORT:-5443}/upload
    docroot: $PATH_UPLOAD
    custom_headers:
      "Access-Control-Allow-Origin": "https://@HOST@"
      "Access-Control-Allow-Methods": "GET,HEAD,PUT,OPTIONS"
      "Access-Control-Allow-Headers": "Content-Type"
EOF
  fi
fi
#
### MOD_LAST #############################################
#
if [ "${MOD_LAST_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_last.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_last.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_last.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_last.yml <<EOF;
modules:
  mod_last: {}
EOF
  fi
fi
#
### MOD_MAM #############################################
#
if [ "${MOD_MAM_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_mam.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_mam.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_mam.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_mam.yml <<EOF;
modules:
  mod_mam:
    assume_mam_usage: true
    default: always
EOF
  fi
fi
#
### MOD_MQTT #############################################
#
if [ "${LISTENER_MQTT_ENABLED:-false}" = true ]; then
  echo ">>> creating link to ../mod_mqtt.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_mqtt.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_mqtt.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_mqtt.yml <<EOF;
modules:
  mod_mqtt: {}
EOF
  fi
fi
#
### MOD_MUC #############################################
#
if [ "${MOD_MUC_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_muc.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_muc.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_muc.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_muc.yml <<EOF;
modules:
  mod_muc:
    access:
      - allow
    access_admin:
      - allow: admin
    access_create: muc_create
    access_persistent: muc_create
    access_mam:
      - allow
    default_room_options:
      mam: true
EOF
  fi
fi
#
### MOD_MUC_ADMIN #############################################
#
if [ "${MOD_MUC_ADMIN_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_muc_admin.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_muc_admin.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_muc_admin.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_muc_admin.yml <<EOF;
modules:
  mod_muc_admin: {}
EOF
  fi
fi
#
### MOD_OFFLINE #############################################
#
if [ "${MOD_OFFLINE_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_offline.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_offline.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_offline.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_offline.yml <<EOF;
modules:
  mod_offline:
    access_max_user_messages: max_user_offline_messages
EOF
  fi
fi
#
### MOD_PING #############################################
#
if [ "${MOD_PING_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_ping.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_ping.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_ping.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_ping.yml <<EOF;
modules:
  mod_ping: {}
EOF
  fi
fi
#
### MOD_PRIVACY #############################################
#
if [ "${MOD_PRIVACY_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_privacy.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_privacy.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_privacy.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_privacy.yml <<EOF;
modules:
  mod_privacy: {}
EOF
  fi
fi
#
### MOD_PRIVATE #############################################
#
if [ "${MOD_PRIVATE_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_private.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_private.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_private.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_private.yml <<EOF;
modules:
  mod_private: {}
EOF
  fi
fi
#
### MOD_PROXY65 #############################################
#
if [ "${MOD_PROXY65_ENABLED:-false}" = true ]; then
  echo ">>> creating link to ../mod_proxy65.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_proxy65.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_proxy65.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_proxy65.yml <<EOF;
modules:
  mod_proxy65:
    access: local
    max_connections: 5
EOF
  fi
fi
#
### MOD_PUBSUB #############################################
#
if [ "${MOD_PUBSUB_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_pubsub.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_pubsub.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_pubsub.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_pubsub.yml <<EOF;
modules:
  mod_pubsub:
    access_createnode: pubsub_createnode
    plugins:
      - flat
      - pep
    force_node_config:
      ## Avoid buggy clients to make their bookmarks public
      storage:bookmarks:
        access_model: whitelist
EOF
  fi
fi
#
### MOD_PUSH #############################################
#
if [ "${MOD_PUSH_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_push.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_push.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_push.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_push.yml <<EOF;
modules:
  mod_push: {}
EOF
  fi
fi
#
### MOD_PUSH_KEEPALIVE #############################################
#
if [ "${MOD_PUSH_KEEPALIVE_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_push_keepalive.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_push_keepalive.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_push_keepalive.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_push_keepalive.yml <<EOF;
modules:
  mod_push_keepalive: {}
EOF
  fi
fi
#
### MOD_REGISTER #############################################
#
if [ "${MOD_REGISTER_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_register.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_register.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_register.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_register.yml <<EOF;
modules:
  mod_register:
    ## Only accept registration requests from the "trusted"
    ## network (see access_rules section above).
    ## Think twice before enabling registration from any
    ## address. See the Jabber SPAM Manifesto for details:
    ## https://github.com/ge0rg/jabber-spam-fighting-manifesto
    ip_access: trusted_network
EOF
  fi
fi
#
### MOD_ROSTER #############################################
#
if [ "${MOD_ROSTER_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_roster.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_roster.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_roster.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_roster.yml <<EOF;
modules:
  mod_roster:
    versioning: true
EOF
  fi
fi
#
### MOD_S2S_DIALBACK #############################################
#
if [ "${MOD_S2S_DIALBACK_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_s2s_dialback.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_s2s_dialback.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_s2s_dialback.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_s2s_dialback.yml <<EOF;
modules:
  mod_s2s_dialback: {}
EOF
  fi
fi
#
### MOD_SHARED_ROSTER #############################################
#
if [ "${MOD_SHARED_ROSTER_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_shared_roster.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_shared_roster.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_shared_roster.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_shared_roster.yml <<EOF;
modules:
  mod_shared_roster: {}
EOF
  fi
fi
#
### MOD_STREAM_MGMT #############################################
#
if [ "${MOD_STREAM_MGMT_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_stream_mgmt.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_stream_mgmt.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_stream_mgmt.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_stream_mgmt.yml <<EOF;
modules:
  mod_stream_mgmt:
    resend_on_timeout: if_offline
EOF
  fi
fi
#
### MOD_STUN_DISCO #############################################
#
if [ "${MOD_STUN_DISCO_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_stun_disco.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_stun_disco.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_stun_disco.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_stun_disco.yml <<EOF;
modules:
  mod_stun_disco: {}
EOF
  fi
fi
#
### MOD_VCARD #############################################
#
if [ "${MOD_VCARD_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_vcard.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_vcard.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_vcard.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_vcard.yml <<EOF;
modules:
  mod_vcard: {}
EOF
  fi
fi
#
### MOD_VCARD_XUPDATE #############################################
#
if [ "${MOD_VCARD_XUPDATE_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_vcard_xupdate.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_vcard_xupdate.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_vcard_xupdate.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_vcard_xupdate.yml <<EOF;
modules:
  mod_vcard_xupdate: {}
EOF
  fi
fi
#
### MOD_VERSION #############################################
#
if [ "${MOD_VERSION_ENABLED:-true}" = true ]; then
  echo ">>> creating link to ../mod_version.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/mod_version.yml
EOF
  if [ ! -f $PATH_MODULE_CONFIG/mod_version.yml ]; then
    cat > $PATH_MODULE_CONFIG/mod_version.yml <<EOF;
modules:
  mod_version:
    show_os: false
EOF
  fi
fi
#
### Additional "non-default" core-modules #############################################
#
if [ ! -z $ADDITIONAL_CORE_MODULE_1_NAME ] || [ ! -z $ADDITIONAL_CORE_MODULE_2_NAME ] || [ ! -z $ADDITIONAL_CORE_MODULE_3_NAME ]; then
echo ">>> "
echo ">>> ======================================================================="
echo ">>> Configuring additional non-default ejabberd core modules"
echo ">>> "
cat >> $CONFIGFILE <<EOF;
# additionally enabled core-modules, defined by environment variables and mounted config files
EOF
if [ ! -z $ADDITIONAL_CORE_MODULE_1_NAME ]; then
  echo ">>> creating link to ../$ADDITIONAL_CORE_MODULE_1_NAME.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/$ADDITIONAL_CORE_MODULE_1_NAME.yml
EOF
fi
if [ ! -z $ADDITIONAL_CORE_MODULE_2_NAME ]; then
  echo ">>> creating link to ../$ADDITIONAL_CORE_MODULE_2_NAME.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/$ADDITIONAL_CORE_MODULE_2_NAME.yml
EOF
fi
if [ ! -z $ADDITIONAL_CORE_MODULE_3_NAME ]; then
  echo ">>> creating link to ../$ADDITIONAL_CORE_MODULE_3_NAME.yml"
  cat >> $CONFIGFILE <<EOF;
  - $PATH_MODULE_CONFIG/$ADDITIONAL_CORE_MODULE_3_NAME.yml
EOF
fi
fi
#
### Additional non-core-modules #############################################
#
if [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME ] || [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME ] || [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME ]; then
  echo ">>> "
  echo ">>> ======================================================================="
  echo ">>> Configuring additional ejabberd contribution modules, starting ejabberd@$(hostname -s) to install contribution modules"
  echo ">>> "
  $PATH_EJABBERD_HOME/bin/ejabberdctl start
  sleep 15s
  $PATH_EJABBERD_HOME/bin/ejabberdctl modules_update_specs
if [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME ]; then
  echo ">>> installing $INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME"
  $PATH_EJABBERD_HOME/bin/ejabberdctl module_install $INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME
  cp $PATH_MODULE_CONFIG/$INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME.yml $PATH_EJABBERD_HOME/.ejabberd-modules/$INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME/conf/$INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME.yml
fi
if [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME ]; then
  echo ">>> installing $INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME"
  $PATH_EJABBERD_HOME/bin/ejabberdctl module_install $INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME
  cp $PATH_MODULE_CONFIG/$INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME.yml $PATH_EJABBERD_HOME/.ejabberd-modules/$INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME/conf/$INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME.yml
fi
if [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME ]; then
  echo ">>> installing $INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME"
  $PATH_EJABBERD_HOME/bin/ejabberdctl module_install $INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME
  cp $PATH_MODULE_CONFIG/$INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME.yml $PATH_EJABBERD_HOME/.ejabberd-modules/$INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME/conf/$INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME.yml
fi
  echo ">>> "
  echo ">>> Finished ejabberd contribution modules installation,"
  echo ">>> stopping ejabberd@$(hostname -s) and waiting for 10 seconds"
  echo ">>> "
  $PATH_EJABBERD_HOME/bin/ejabberdctl stop
  sleep 10s
fi
echo ">>> "
echo ">>> ======================================================================="
echo ">>> "
echo ">>>                    Main configuration setup done"
echo ">>>"
echo ">>> ======================================================================="
echo ">>> "
echo ">>>     Next step: joining cluster and/ or to start in foreground mode"
echo ">>> "

### Local Variables:
### mode: yaml
### End:
### vim: set filetype=yaml tabstop=8
