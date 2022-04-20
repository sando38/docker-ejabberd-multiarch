# Docker image for ejabberd xmpp server

This is a multi-arch [ejabberd](https://docs.ejabberd.im/ "ejabberd") docker image, currently built for

* linux/amd64
* linux/arm64
* linux/386
* linux/arm/v7

and is based on Debian Bullseye Slim.

[Docker Hub link](https://hub.docker.com/r/sando38/docker-ejabberd-multiarch)

There may be further architectures supported in future. If you need another, raise an issue on github.

The docker files, etc. are available on [github](https://github.com/sando38/docker-ejabberd-multiarch).

## Usage

In the current setup, the image provides a default ejabberd configuration file, which will provide a running server at localhost. However, it is strongly advised to tune the configuration file. This may be achieved in two ways:

* using various environment variables like described below,
* providing/ mounting own configuration file(s)

To pull the image, just refer to the Docker Hub repository:

`docker pull sando38/docker-ejabberd-multiarch`

The image will run in ejabberd foreground mode, if started this way:

`docker run -d sando38/docker-ejabberd-multiarch --name ejabberd`

The image can also run in a less "privileged" mode:

```
docker run -d \
  --name ejabberd \
  --user 999:999 \
  --security-opt no-new-privileges \
  --cap-drop=ALL \
  sando38/docker-ejabberd-multiarch
```

Inspect the running container with

`docker logs < container name >`

## Tags

The image has several tags. Future tags will potentially support more architectures. To go with the newest image, just use the `latest` tag.

`vXX-XX` represents the official ejabberd release, `-vX` is the version of the Docker image, which rise in number, e.g. due to bug fixes, enhancements, etc.

| TAGS  | Description  | Architectures  |
| ------------ | ------------ | ------------ |
| latest  | Built from master branch, may be unstable  | linux/amd64,linux/386,linux/arm64,linux/arm/v7  |
| v21-12-v2  | [offical ejabberd release notes](https://www.process-one.net/blog/ejabberd-21-12/)  | linux/amd64,linux/386,linux/arm64,linux/arm/v7  |


## Configure the image

This image provides a way to adjust the standard configuration file `ejabberd.yml` at initial startup. If the configuration file is not made persistent (e.g. via a mounted volume), the configuration file will be (re)created at every startup. The configuration file will not be configured, if one provides an own `ejabberd.yml` file and mounts it into the container.

**Mountpath:**
` -v /path/to/ejabberd.yml:/home/ejabberd/etc/ejabberd/ejabberd.yml`

[Link to ejabberd.yml example file](https://github.com/processone/ejabberd/blob/master/ejabberd.yml.example "Link to ejabberd.yml example file")

## Volume mounts

It is advised to make some data persistent. Those can be mounted here:

```
volumes:
  - /path/to/configfiles:/home/ejabberd/etc/ejabberd    # for configuration files
  - /path/to/database:/home/ejabberd/var/lib/ejabberd   # mnesia database
  - /path/to/fileserver/docs:/home/ejabberd/files       # for HTTP fileserver functionality
  - /path/to/cert-files:/home/ejabberd/tls              # for tls certicates
  - /path/to/upload/files:/home/ejabberd/upload         # for HTTP upload functionality
```

## Parameters to configure ejabberd

If default column is empty, then there is no default.

Parameters in **bold** can be adjusted according to [ejabberd docs](https://docs.ejabberd.im/admin/configuration/ "ejabberd docs"). The Parameters may have a slightly different naming.

### General settings
| Parameter  | Description  | Default  |
| ------------ | ------------ | ------------ |
| XMPP_DOMAIN0  | XMPP Server Domain (with a matching TLS certificate)  | localhost  |
| XMPP_DOMAIN1  | Additional XMPP Server Domain (with a matching TLS certificate)  |   |
| XMPP_DOMAIN2  | Additional XMPP Server Domain (with a matching TLS certificate)  |   |
| **LOGLEVEL**  | **Possible values**: none, emergency, alert, critical, error, warning, notice, info, debug  |  info |
| **HIDE_SENSITIVE_LOG_DATA**  | Disables logging of ip addresses of users  | false  |
| **LANGUAGE_DEFAULT**  | Default language of the xmpp server  | en  |
| JID_ADMIN_USER0  | Admin account of ejabberd server  | admin@$XMPP_DOMAIN0  |
|   |   |   |

Further settings for shapers will be added in the future.

### Database settings

| Parameter  | Description  | Default  |
| ------------ | ------------ | ------------ |
| **DEFAULT_DB**  | Defines the default database for ejabberd and its functions/ modules. Options are: `mnesia` or `sql`  | mnesia  |
| **DEFAULT_RAM_DB**  | Defines the default in-memory storage. Options are: `mnesia`, `sql` or `redis`  | mnesia  |
|   |   |   |

For more information for the paramters, please look at [ejabberd documentation](https://docs.ejabberd.im/admin/configuration/database/). When using a database which is not `sqlite`, the database must exist prior to ejabberd startup and must be preconfigured with the respective [SQL schema](https://docs.ejabberd.im/admin/configuration/toplevel/#new-sql-schema).

SQL database must be configure either if `DEFAULT_DB=sql` or `DEFAULT_RAM_DB=sql`.

| Parameter  | Description  | Default  |
| ------------ | ------------ | ------------ |
| **DB_TYPE**  | defines the database driver. Options are: `mysql`, `pgsql`, `sqlite`  | pgsql  |
| **DB_SERVER_ADDRESS**  | Host address or ip of the database server  | localhost  |
| **DB_USER**  | Database user name  | ejabberd  |
| **DB_PASSWORD**  | Database user password  |   |
| **DB_DATABASE_NAME**  | Name of the database. For SQLite this must be a full path to a database file.  | ejabberd  |
| **DB_NEW_SQL_SCHEMA**  | Shall be considered, if more than one XMPP domain is used. [Link](https://docs.ejabberd.im/admin/configuration/toplevel/#new-sql-schema)  | false  |
| **DB_QUEUE_TYPE**  |   | ram  |
| **DB_START_INTERVAL**  |   | 30  |
| **DB_QUERY_TIMEOUT**  |   | 60  |
| **DB_CONNECTION_TIMEOUT**  |   | 5  |
| **DB_SERVER_PORT**  | [defaults](https://docs.ejabberd.im/admin/configuration/toplevel/#sql-port) to depending on the db type  |   |
| **DB_PREPARED_STATEMENTS**  | only for type `pgsql`. Options: `true` or `false`  | true  |
| **DB_KEEPALIVE_INTERVAL**  | to keep the database connection alive, measures in seconds.  |   |
| **DB_POOL_SIZE**  | If type `sqlite` is used, pool size is hard coded value `1`.  | 10  |
| **DB_SSL**  | only applies to type `mysql` and `pgsql`. Options are `true` or `false`  | false  |
| **DB_SSL_VERIFY**  | wheter to verify or not. If enable, set to `true`. If `true`, it needs DB_SSL_CAFILE_NAME & DB_SSL_CERTFILE_NAME set | false  |
| **DB_SSL_CAFILE_NAME**  | Mounted CA certificate in path `/home/ejabberd/tls`  | ca.pem  |
| **DB_SSL_CERTFILE_NAME**  | Mounted client certificate in path `/home/ejabberd/tls`  | server.pem  |
|   |   |   |

#### REDIS settings

Redis must be defined either, if DEFAULT_RAM_DB=redis or REDIS_ENABLED=true.

| Parameter  | Description  | Default  |
| ------------ | ------------ | ------------ |
| REDIS_ENABLED  | Redis can be activated by setting this to `true`. No default.  |   |
| **REDIS_SERVER_ADDRESS**  | [Description from ejabberd docs](https://docs.ejabberd.im/admin/configuration/database/#redis)  | localhost  |
| **REDIS_SERVER_PORT**  | [Description from ejabberd docs](https://docs.ejabberd.im/admin/configuration/database/#redis)  | 6379  |
| **REDIS_PASSWORD**  | [Description from ejabberd docs](https://docs.ejabberd.im/admin/configuration/database/#redis)  |   |
| **REDIS_DB_NUMBER**  | [Description from ejabberd docs](https://docs.ejabberd.im/admin/configuration/database/#redis)  | 0  |
| **REDIS_POOL_SIZE**  | [Description from ejabberd docs](https://docs.ejabberd.im/admin/configuration/toplevel/#redis-pool-size)  | 10  |
| **REDIS_QUEUE_TYPE**  | [Description from ejabberd docs](https://docs.ejabberd.im/admin/configuration/toplevel/#redis-queue-type)  | ram  |
| **REDIS_CONNECT_TIMEOUT**  | [Description from ejabberd docs](https://docs.ejabberd.im/admin/configuration/database/#redis)  | 1  |
|   |   |   |

### Authentication

Currently only mnesia, sql, ldap or anonymous are supported by the configuration script of this image.

| Parameter  | Description  | Default  |
| ------------ | ------------ | ------------ |
| **AUTH_METHOD**  | Currently supported by this image are `mnesia, sql, ldap, anonymous`  | mnesia  |
| **AUTH_PASSWORD_FORMAT**  | only be valid if AUTH_METHOD is `mnesia` or `sql`, options are: `scram` or `plain`  | scram  |
| **AUTH_SCRAM_HASH**  | hash of scram if AUTH_PASSWORD_FORMAT=scram. Options are `sha`, `sha256`, `sha512`  | sha256  |
|   |   |   |

#### LDAP authentication

These variables only take effect if AUTH_METHOD=ldap. See also [ejabberd docs](https://docs.ejabberd.im/admin/configuration/ldap/) for further explanations.

| Parameter  | Description  | Default  |
| ------------ | ------------ | ------------ |
| **LDAP_BIND_DN**  | if empty, anonymous bind  |   |
| **LDAP_BIND_PW**  | password of the bind user, can be empty  |   |
| **LDAP_USER_BASE_DN**  | BASE DN to query users  |   |
| **LDAP_UID**  | User attribute, e.g. `uid`  | %u |
| **LDAP_UID_ALTERNATIVE**  | alternative user attribute  |   |
| **LDAP_UID_ALTERNATIVE_2**  | another alternative user attribute  |   |
| **LDAP_DEREF_ALIASES**  |   | never  |
| **LDAP_USER_FILTER**  | NOTE: user attribute must not be included since it will be appended automatically  | (objectClass=inetOrgPerson)  |
| **LDAP_ENCRYPT**  | wether to use non-encrypted or encrypted LDAP connection. Options are: `tls` or `none`  | none  |
| **LDAP_TLS_VERIFY**  | Whether to verify the LDAP certificate or not  | false  |
| **LDAP_TLS_VERIFY_DEPTH**  | [Description from ejabberd documentation](https://docs.ejabberd.im/admin/configuration/toplevel/#ldap-tls-depth)  | 1  |
| **LDAP_TLS_CA_CRT_FILE_NAME**  | [Description from ejabberd documentation](https://docs.ejabberd.im/admin/configuration/toplevel/#ldap-tls-cacertfile)  | ca.pem  |
| **LDAP_TLS_CRT_FILE_NAME**  | [Description from ejabberd documentation](https://docs.ejabberd.im/admin/configuration/toplevel/#ldap-tls-certfile)  | server.pem  |
| **LDAP_SERVER_1**  | LDAP host address, if non is provided, defaults to localhost  | localhost  |
| **LDAP_SERVER_2**  | 2nd LDAP host address  |   |
| **LDAP_SERVER_3**  | 3rd LDAP host address  |   |
| **LDAP_PORT**  | LDAP server port to connect.  | `389` or `636`  |
| **LDAP_BACKUP_SERVER_1**  | LDAP backup server if LDAP_SERVER* are not available anymore  |   |
| **LDAP_BACKUP_SERVER_2**  | Alternative LDAP backup server if LDAP_SERVER* are not available anymore  |   |
| **LDAP_BACKUP_SERVER_3**  | Another alternative LDAP backup server if LDAP_SERVER* are not available anymore  |   |
|   |   |   |

### SSL/TLS settings

TLS certificates if not recieved by internal ACME client need to be mounted in to following folder:

`-v /path/to/certfiles:/home/ejabberd/tls`

| Parameter  | Description  | Default  |
| ------------ | ------------ | ------------ |
| DHPARAM_KEYSIZE  | Size of the dhparam key generated at startup if no dhparam file is mounted into the container. Can also be set to `4096`. Mount path is `/home/ejabberd/tls/$DHPARAM_FILE_NAME`  | 2048  |
| DHPARAM_FILE_NAME  | Name of the dhparam file, if own file is mounted. Must be mounted in the same path as the TLS certificates.  | dh.pem  |
| TLS_CRT_FILE_XMPP_DOMAIN0  | Name of matching TLS certificate for XMPP_DOMAIN0, must be mounted into the container | fullchain.pem  |
| TLS_KEY_FILE_XMPP_DOMAIN0  | Name of matching TLS key for XMPP_DOMAIN0, must be mounted into the container | privkey.pem  |
| TLS_CRT_FILE_XMPP_DOMAIN1  | Name of matching TLS certificate for XMPP_DOMAIN1, must be mounted into the container | fullchain.pem  |
| TLS_KEY_FILE_XMPP_DOMAIN1  | Name of matching TLS key for XMPP_DOMAIN1, must be mounted into the container | privkey.pem  |
| TLS_CRT_FILE_XMPP_DOMAIN2  | Name of matching TLS certificate for XMPP_DOMAIN2, must be mounted into the container | fullchain.pem  |
| TLS_KEY_FILE_XMPP_DOMAIN2  | Name of matching TLS key for XMPP_DOMAIN2, must be mounted into the container | privkey.pem  |
| **TLS_CIPHERS**  | TLS ciphers to be offered through ejabberd  | ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256  |
| **TLS_PROTOCOL_SSL_V3_DISABLED**  | Rejects request with *insecure* SSLv3 protocol | true  |
| **TLS_PROTOCOL_TLS_V1_DISABLED**  | Rejects request with *insecure* TLSv1 protocol  | true  |
| **TLS_PROTOCOL_TLS_V1_1_DISABLED**  | Rejects request with *insecure* TLSv1.1 protocol  | true  |
| **TLS_PROTOCOL_TLS_V1_2_DISABLED**  | Rejects request with TLSv1.2 protocol  | false  |
|   |   |   |

### ACME client

For the ACME client to work correctly, the HTTP listener needs to enabled (LISTENER_HTTP_ENABLED=true) and port 80 of the host machine needs to be forwarded to the HTTP listener port (default: 5280). **The HTTP listener is disabled by default.**

| Parameter  | Description  | Default  |
| ------------ | ------------ | ------------ |
| LISTENER_HTTP_ACME_ENABLED  | ACME listening option of HTTP listener is enabled, HTTP listener must be enabled to use ACME client `LISTENER_HTTP_ENABLED=true` | true  |
| **ACME_ENABLED**  | if set to *false*, ACME client will not try to request certificates for the listed XMPP_DOMAIN*s  | true  |
| **ACME_EMAIL**  | needs an email address for registring an account at LetsEncrypt  | name@example.com  |
| **ACME_URL**  | either the staging or production URL from LetsEncrypt  | https://acme-v02.api.letsencrypt.org/directory  |
| **ACME_CERT_TYPE**  | Defines the type of the private key (rsa or ec)  | rsa  |
|   |   |   |

### ejabberd listeners

Definition of the different [XMPP listeners](https://docs.ejabberd.im/admin/configuration/listen/).

#### Client to Server connections (TCP / STARTTLS)

This listener cannot be disabled.

| Parameter  | Description  | Default  |
| ------------ | ------------ | ------------ |
| **LISTENER_C2S_PORT**  | Listening port  | 5222  |
| **LISTENER_C2S_IP**  | Listening ip  | ::  |
| **LISTENER_C2S_STARTTLS**  | Whether to activate STARTTLS or not. This option gets implicitly enabled when enabling LISTENER_C2S_STARTTLS_REQUIRED=true.    | false  |
| **LISTENER_C2S_STARTTLS_REQUIRED**  | Whether to enforce STARTTLS or not. To enforce, set with `true`   | false  |
| **LISTENER_C2S_PROXY_PROTOCOL**  | If ejabberd is behind a layer4 load balancer, this can be set to `true`, if the corresponding load balancer supports HAproxy protocol. Herewith, the real IP addresss of connecting clients are preserved.  | false  |
|   |   |   |

#### Client to Server connections (TLS)

For legacy TLS connections. This may be interesting also to map via port 443, either behind a load balancer or directly with e.g. an iptables rule, since ejabberd cannot listen to 443 (privileged ports) directly.

| Parameter  | Description  | Default  |
| ------------ | ------------ | ------------ |
| LISTENER_C2S_LEGACY_TLS_ENABLED  | Setting to `true` enables the listener | false  |
| **LISTENER_C2S_LEGACY_TLS_PORT**  | Listening port  | 5223  |
| **LISTENER_C2S_LEGACY_TLS_IP**  | Listening ip  | ::  |
| **LISTENER_C2S_LEGACY_TLS_PROXY_PROTOCOL**  | If ejabberd is behind a layer4 load balancer, this can be set to `true`, if the corresponding load balancer supports HAproxy protocol. Herewith, the real IP addresss of connecting clients are preserved.  | false  |
|   |   |   |

#### Server to Server connections (TCP / STARTTLS)

For legacy TLS connections. This may be interesting also to map via port 443, either behind a load balancer or directly with e.g. an iptables rule, since ejabberd cannot listen to 443 (privileged ports) directly.

| Parameter  | Description  | Default  |
| ------------ | ------------ | ------------ |
| LISTENER_S2S_ENABLED  | Setting to `true` enables the listener | false  |
| **LISTENER_S2S_PORT**  | Listening port  | 5269  |
| **LISTENER_S2S_IP**  | Listening ip  | ::  |
| **LISTENER_S2S_USE_STARTTLS**  | Whether to support STARTTLS or not [Link](https://docs.ejabberd.im/admin/configuration/toplevel/#s2s-use-starttls). To enforce, set to `required`. To enable, set to `optional`  | false  |
| **LISTENER_S2S_PROXY_PROTOCOL**  | If ejabberd is behind a layer4 load balancer, this can be set to `true`, if the corresponding load balancer supports HAproxy protocol. Herewith, the real IP addresss of connecting servers are preserved.  | false  |
|   |   |   |

#### Server to Server connections (TLS)

For legacy TLS connections. This may be interesting also to map via port 443, either behind a load balancer or directly with e.g. an iptables rule, since ejabberd cannot listen to 443 (privileged ports) directly.

| Parameter  | Description  | Default  |
| ------------ | ------------ | ------------ |
| LISTENER_S2S_LEGACY_TLS_ENABLED  | Setting to `true` enables the listener | false  |
| **LISTENER_S2S_LEGACY_TLS_PORT**  | Listening port  | 5270  |
| **LISTENER_S2S_LEGACY_TLS_IP**  | Listening ip  | ::  |
| **LISTENER_S2S_LEGACY_TLS_PROXY_PROTOCOL**  | If ejabberd is behind a layer4 load balancer, this can be set to `true`, if the corresponding load balancer supports HAproxy protocol. Herewith, the real IP addresss of connecting clients are preserved.  | false  |
|   |   |   |

#### STUN-TURN listener

ejabberd offers a STUN-TURN listener. In a docker environment, TURN service may be problematic, because docker is not handling large port ranges well, which would be required by the TURN feature. More information [here](https://docs.ejabberd.im/admin/configuration/listen/#ejabberd-stun-1).

Additinally, it is advised to also set SRV records for the XMPP domains in the domains' DNS server.

Please note: STUN-TURN listener does not support HAproxy Protocol as of now (ejabberd-v21-12).

##### STUN-TURN (UDP)

| Parameter  | Description  | Default  |
| ------------ | ------------ | ------------ |
| LISTENER_STUNTURN_UDP_ENABLED  | Setting to `true` enables the listener | false  |
| **LISTENER_STUNTURN_UDP_PORT**  | Listening port  | 3478  |
| **LISTENER_STUNTURN_UDP_IP**  | Listening ip  | ::  |
| **LISTENER_STUNTURN_UDP_USE_TURN**  | Wheter to offer TURN service or not. To enable, set `true`.  | false  |
| **LISTENER_STUNTURN_UDP_TURN_IP4**  | The public ip address of the host machine  | 10.20.30.40  |
| **LISTENER_STUNTURN_UDP_TURN_MIN_PORT**  | Minimum port range of the TURN services. Note: Please consider the range *smaller* in a docker / kubernetes environment, if you do not use the host network.  | 49152  |
| **LISTENER_STUNTURN_UDP_TURN_MAX_PORT**  | Maximum port range of the TURN services. Note: Please consider the range *smaller* in a docker / kubernetes environment, if you do not use the host network.  | 65535  |
|   |   |   |

##### STUN-TURN (TCP)

STUN-TURN via TCP is non-default and should not be considered.

| Parameter  | Description  | Default  |
| ------------ | ------------ | ------------ |
| LISTENER_STUNTURN_TCP_ENABLED  | Setting to `true` enables the listener | false  |
| **LISTENER_STUNTURN_TCP_PORT**  | Listening port  | 3478  |
| **LISTENER_STUNTURN_TCP_IP**  | Listening ip  | ::  |
| **LISTENER_STUNTURN_TCP_USE_TURN**  | Wheter to offer TURN service or not. To enable, set `true`.  | false  |
| **LISTENER_STUNTURN_TCP_TURN_IP4**  | The public ip address of the host machine  | 10.20.30.40  |
| **LISTENER_STUNTURN_TCP_TURN_MIN_PORT**  | Minimum port range of the TURN services. Note: Please consider the range *smaller* in a docker / kubernetes environment, if you do not use the host network.  | 49152  |
| **LISTENER_STUNTURN_TCP_TURN_MAX_PORT**  | Maximum port range of the TURN services. Note: Please consider the range *smaller* in a docker / kubernetes environment, if you do not use the host network.  | 65535  |
|   |   |   |

##### STUNS-TURNS (TLS)

STUN-TURN via TLS. This may be interesting also to map via port 443, either behind a load balancer or directly with e.g. an iptables rule, since ejabberd cannot listen to 443 (privileged ports) directly.

| Parameter  | Description  | Default  |
| ------------ | ------------ | ------------ |
| LISTENER_STUNTURN_TCP_ENABLED  | Setting to `true` enables the listener | false  |
| **LISTENER_STUNTURN_TCP_PORT**  | Listening port  | 5349  |
| **LISTENER_STUNTURN_TCP_IP**  | Listening ip  | ::  |
| **LISTENER_STUNTURN_TCP_USE_TURN**  | Wheter to offer TURN service or not. To enable, set `true`.  | false  |
| **LISTENER_STUNTURN_TCP_TURN_IP4**  | The public ip address of the host machine  | 10.20.30.40  |
| **LISTENER_STUNTURN_TCP_TURN_MIN_PORT**  | Minimum port range of the TURN services. Note: Please consider the range *smaller* in a docker / kubernetes environment, if you do not use the host network.  | 49152  |
| **LISTENER_STUNTURN_TCP_TURN_MAX_PORT**  | Maximum port range of the TURN services. Note: Please consider the range *smaller* in a docker / kubernetes environment, if you do not use the host network.  | 65535  |
|   |   |   |

#### HTTP listener

This listener may only be configured for test purposes and/ or ACME client usage.

| Parameter  | Description  | Default  |
| ------------ | ------------ | ------------ |
| LISTENER_HTTP_ENABLED  | Setting to `true` enables the listener | false  |
| **LISTENER_HTTP_PORT**  | Listening port  | 5280  |
| **LISTENER_HTTP_IP**  | Listening ip  | ::  |
| **LISTENER_HTTP_PROXY_PROTOCOL**  | If ejabberd is behind a layer4 load balancer, this can be set to `true`, if the corresponding load balancer supports HAproxy protocol. Herewith, the real IP addresss of connecting clients are preserved.  | false  |
| **LISTENER_HTTP_ADMIN_ENABLED**  | To reach the admin interface at http://XMPP_DOMAIN*:LISTENER_HTTP_PORT/admin  | false  |
| **LISTENER_HTTP_ACME_ENABLED**  | To enable ACME client challenge response. To make it work, there must be some mechanism to forward port 80 from the host machine to the LISTENER_HTTP_PORT  | true  |
|   |   |   |

#### HTTPS listener

The general HTTP services listener for various services, which may be offered through ejabberd.

| Parameter  | Description  | Default  |
| ------------ | ------------ | ------------ |
| LISTENER_HTTPS_ENABLED  | Setting to `false` disables the listener | true  |
| **LISTENER_HTTPS_PORT**  | Listening port  | 5443  |
| **LISTENER_HTTPS_IP**  | Listening ip  | ::  |
| **LISTENER_HTTPS_PROXY_PROTOCOL**  | If ejabberd is behind a layer4 load balancer, this can be set to `true`, if the corresponding load balancer supports HAproxy protocol. Herewith, the real IP address of connecting clients are preserved.  | false  |
| **LISTENER_HTTPS_ADMIN_ENABLED**  | To reach the admin interface at https://XMPP_DOMAIN*:LISTENER_HTTP_PORT/admin  | true  |
| **LISTENER_HTTPS_API_ENABLED**  | HTTP API listener, accessible at https://XMPP_DOMAIN*:LISTENER_HTTP_PORT/api, to enable set to `true`  | false  |
| **LISTENER_HTTPS_BOSH_ENABLED**  | HTTP bosh listener, accessible at https://XMPP_DOMAIN*:LISTENER_HTTP_PORT/bosh, to disable set to `false`  | true  |
| **LISTENER_HTTPS_CONVERSEJS_ENABLED**  | Please note: if mod_conversejs shall be enabled (set to `true`), either HTTPS bosh or websocket must be enabled as well. If both are enabled, then websocket will be configured. Link to [ejabberd docs](https://docs.ejabberd.im/admin/configuration/modules/#mod-conversejs). The conversejs client is accessible at https://XMPP_DOMAIN*:LISTENER_HTTPS_PORT/conversejs, please also consider the module `mod_conversejs` configurations | false  |
| **LISTENER_HTTPS_FILESERVER_ENABLED**  | HTTP fileserver, accessible at https://XMPP_DOMAIN*:LISTENER_HTTP_PORT/files, to enable set to `true`, please also consider the module `mod_http_fileserver` configurations | false  |
| **LISTENER_HTTPS_UPLOAD_ENABLED**  | HTTP upload service, accessible at https://XMPP_DOMAIN*:LISTENER_HTTP_PORT/upload, to disable set to `false`, please also consider the module `mod_http_upload` configurations | true  |
| **LISTENER_HTTPS_WS_ENABLED**  | HTTP websocket listener. The websocket is available via wss://XMPP_DOMAIN*:LISTENER_HTTP_PORT/ws  | true  |
|   |   |   |

#### MQTT listener

More information are [here](https://docs.ejabberd.im/admin/configuration/listen/#mod-mqtt)

| Parameter  | Description  | Default  |
| ------------ | ------------ | ------------ |
| LISTENER_MQTT_ENABLED  | Setting to `true` enables the listener, please also consider the module `mod_mqtt` configurations | false  |
| **LISTENER_MQTT_PORT**  | Listening port  | 1883  |
| **LISTENER_MQTT_IP**  | Listening ip  | ::  |
| **LISTENER_MQTT_TLS**  |   | false  |
|   |   |   |

### Core modules addressed by the startup script of this image

These is a list of modules addressed by the startup script. For some it may be advised to mount an own configuration script at the following path:

`-v /path/to/module/configuration/files:/home/ejabberd/etc/ejabberd/config-modules`

A general description of modules options can be found here: [Ejabberd docs](https://docs.ejabberd.im/admin/configuration/modules/).

Some modules will only be enabled if the respective listener is active (e.g. mod_bosh, mod_conversejs mod_http_api, etc.)

Some modules depend on other modules to be anabled. For example, mod_avatar depends on mod_pubsub, mod_vcard and mod_vcard_xupdate.

| Parameter  | Description  | Default  |
| ------------ | ------------ | ------------ |
| MOD_ADHOC_ENABLED  | **mod_adhoc.yml**  | true  |
| MOD_ADMIN_EXTRA_ENABLED  | **mod_admin_extra.yml**  | true  |
| MOD_ANNOUNCE_ENABLED  | **mod_announce.yml**  | true  |
| MOD_AVATAR_ENABLED  | **mod_avatar.yml**  | true  |
| MOD_BLOCKING_ENABLED  | **mod_blocking.yml**  | true  |
| LISTENER_HTTPS_BOSH_ENABLED  | **mod_bosh.yml**  | true  |
| MOD_CAPS_ENABLED  | **mod_caps.yml**  | true  |
| MOD_CARBONCOPY_ENABLED  | **mod_carboncopy.yml**  | true  |
| MOD_CLIENT_STATE_ENABLED  | **mod_client_state.yml**  | true  |
| MOD_CONFIGURE_ENABLED  | **mod_configure.yml**  | true  |
| LISTENER_HTTPS_CONVERSEJS_ENABLED  | **mod_conversejs.yml** Please note: if mod_conversejs shall be enabled, either HTTPS bosh or websocket must be enabled as well. If both are enabled, then websocket will be configured. Link to [ejabberd docs](https://docs.ejabberd.im/admin/configuration/modules/#mod-conversejs). The conversejs client may be accessible at https://XMPP_DOMAIN*:LISTENER_HTTPS_PORT/conversejs | false  |
| MOD_DISCO_ENABLED  | **mod_disco.yml**  | true  |
| MOD_FAIL2BAN_ENABLED  | **mod_fail2ban.yml**  | true  |
| LISTENER_HTTPS_API_ENABLED  | **mod_http_api.yml**  | false  |
| LISTENER_HTTPS_FILESERVER_ENABLED  | **mod_http_fileserver.yml** it is advised to mount own configuration file for HTTP fileserver if desired. Files will be served at https://XMPP_DOMAIN*:LISTENER_HTTPS_PORT/files | false  |
| LISTENER_HTTPS_UPLOAD_ENABLED  | **mod_http_upload.yml**  | true  |
| MOD_LAST_ENABLED  | **mod_last.yml**  | true  |
| MOD_MAM_ENABLED  | **mod_mam.yml**  | true  |
| LISTENER_MQTT_ENABLED  | **mod_mqtt.yml**  | false  |
| MOD_MUC_ENABLED  | **mod_muc.yml**  | true  |
| MOD_MUC_ADMIN_ENABLED  | **mod_muc_admin.yml**  | true  |
| MOD_OFFLINE_ENABLED  | **mod_offline.yml**  | true  |
| MOD_PING_ENABLED  | **mod_ping.yml**  | true  |
| MOD_PRIVACY_ENABLED  | **mod_privacy.yml**  | true  |
| MOD_PRIVATE_ENABLED  | **mod_private.yml**  | true  |
| MOD_PROXY65_ENABLED  | **mod_proxy65.yml**  | false  |
| MOD_PUBSUB_ENABLED  | **mod_pubsub.yml**  | true  |
| MOD_PUSH_ENABLED  | **mod_push.yml**  | true  |
| MOD_PUSH_KEEPALIVE_ENABLED  | **mod_push_keepalive.yml**  | true  |
| MOD_REGISTER_ENABLED  | **mod_register.yml**  | true  |
| MOD_ROSTER_ENABLED  | **mod_roster.yml**  | true  |
| MOD_S2S_DIALBACK_ENABLED  | **mod_s2s_dialback.yml**  | true  |
| MOD_SHARED_ROSTER_ENABLED  | **mod_shared_roster.yml**  | true  |
| MOD_STREAM_MGMT_ENABLED  | **mod_stream_mgmt.yml**  | true  |
| MOD_STUN_DISCO_ENABLED  | **mod_stun_disco.yml**  | true  |
| MOD_VCARD_ENABLED  | **mod_vcard.yml**  | true  |
| MOD_VCARD_XUPDATE_ENABLED  | **mod_vcard_xupdate.yml**  | true  |
| MOD_VERSION_ENABLED  | **mod_version.yml**  | true  |
|   |   |   |

### Additional modules

Activation of additional core modules. No configuration file will be generated by the startup script, therefore, they must be mounted into the following path:

`-v /path/to/module/configuration/files:/home/ejabberd/etc/ejabberd/config-modules`

To activate the module `mod_http_upload_quota`, e.g. the parameter `ADDITIONAL_CORE_MODULE_1_NAME=mod_http_upload_quota` is set and the configfile `mod_http_upload_quota.yml` is mounted.

| Parameter  | Description  | Default  |
| ------------ | ------------ | ------------ |
| ADDITIONAL_CORE_MODULE_1_NAME  | If parameter is set, then module will be added to the configuration file. To make it function, a module configuration file must be mounted at the mentioned path above with the the following name: `$ADDITIONAL_CORE_MODULE_1_NAME.yml` , e.g. `mod_http_upload_quota.yml` |   |
| ADDITIONAL_CORE_MODULE_2_NAME  | If parameter is set, then module will be added to the configuration file. To make it function, a module configuration file must be mounted at the mentioned path above with the the following name: `$ADDITIONAL_CORE_MODULE_2_NAME.yml` , e.g. `mod_metrics.yml` |   |
| ADDITIONAL_CORE_MODULE_3_NAME  | If parameter is set, then module will be added to the configuration file. To make it function, a module configuration file must be mounted at the mentioned path above with the the following name: `$ADDITIONAL_CORE_MODULE_3_NAME.yml` , e.g. `mod_shared_roster_ldap.yml` |   |
|   |   |   |

Currently three additional modules (configurations) may be enabled. Practically, however, a configuration file can include more than one module, e.g. a configuration could look like this for an example config file `additional-modules.yml`:

```
modules:
  mod_http_upload_quota:
    max_days: 30
  mod_metrics:
    ip: 127.0.0.1
    port: 11111
```

This would activate two modules with only using one parameter (e.g. `ADDITIONAL_CORE_MODULE_1_NAME=additional-modules`)

### Load new modules from ejabberd contributions

Furthermore, the startup script can load additional modules from [ejabberd contributions](https://github.com/processone/ejabberd-contrib). No configuration file will be generated by the startup script, therefore, they must be mounted into the following path:

`-v /path/to/module/configuration/files:/home/ejabberd/etc/ejabberd/config-modules`

To activate the ejabberd contributions module `mod_cron`, e.g. the parameter `INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME=mod_cron` is set and the configfile `mod_cron.yml` is mounted.

| Parameter  | Description  | Default  |
| ------------ | ------------ | ------------ |
| INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME  | If parameter is set, then module will be added to the configuration file. To make it function, a module configuration file must be mounted at the mentioned path above with the the following name: `$INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME.yml` , e.g. `mod_cron.yml`  |   |
| INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME  | If parameter is set, then module will be added to the configuration file. To make it function, a module configuration file must be mounted at the mentioned path above with the the following name: `$INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME.yml` , e.g. `mod_default_contacts.yml`  |   |
| INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME  | If parameter is set, then module will be added to the configuration file. To make it function, a module configuration file must be mounted at the mentioned path above with the the following name: `$INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME.yml` , e.g. `mod_default_rooms.yml`  |   |
|   |   |   |

Currently only three additional contributions modules can be added to the script.

## Notes on the image

ToDos are tracked via the [github](https://github.com/sando38/docker-ejabberd-multiarch) issue tracker and milestones.
