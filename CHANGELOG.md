### unreleased

#### Changes
* fix non-working eturnalctl invocations
* erlang cookie does not need to be mounted anymore when running in readonly mode

### v3.1.0

#### Changes
* Support for HAproxy protocol option for stun-turn tcp listener through the startup script with the following environment variables
  * `LISTENER_STUNTURN_TCP_PROXY_PROTOCOL=true`, default is `false`
  * `LISTENER_STUNSTURNS_TLS_PROXY_PROTOCOL=true`, default is `false`
* by default public `turn_ipv4_address` is now tried to be derived from `$XMPP_DOMAIN1` variable, it is recommended, however, to specify it with the following - already known - variables for the respective listeners:
  * `LISTENER_STUNTURN_UDP_TURN_IP4`
  * `LISTENER_STUNTURN_TCP_TURN_IP4`
  * `LISTENER_STUNSTURNS_TLS_TURN_IP4`
* New CAPTCHA image which can be retrieved with suffix `-captcha`. The image is available from `v3.1.0` onwards. Further details can be found in the [README](https://github.com/sando38/docker-ejabberd-multiarch#CAPTCHA)
* New variable `LISTENER_HTTPS_REGISTER_WEB_ENABLED` to enable in-band registration via https. It requires `MOD_REGISTER_ENABLED=true`.
* Default values changed for `mod_register`.

### v3.0.0

This release brings some bigger changes, because the underlying image has changed. It is now based on the [official process one docker image](https://github.com/processone/ejabberd/blob/master/.github/container/Dockerfile), with some slight variations, e.g. reducing # of layers in final image.

Due to this changes some of the configuration paths have changed as well.

Please, also check the official upgrade notes for ejabberd [from 21.12 to 22.05](https://docs.ejabberd.im/admin/upgrade/from_21.12_to_22.05/).

#### Breaking changes
* ejabberd user and group is now `9000:9000`
* changing DOMAIN Variables, valid for XMPP_DOMAIN* and TLS_* variables
  * *_DOMAIN0 -> *_DOMAIN1 (e.g. XMPP_DOMAIN0 -> XMPP_DOMAIN1)
  * *_DOMAIN1 -> *_DOMAIN2
  * *_DOMAIN2 -> *_DOMAIN3
* path for custom files (new)
```
volumes:
  - /path/to/config-files:/opt/ejabberd/conf      # for (custom) configuration files
  - /path/to/database:/opt/ejabberd/database      # mnesia database & acme client certificates
  - /path/to/fileserver/docs:/opt/ejabberd/files  # for HTTP fileserver functionality
  - /path/to/cert-files:/opt/ejabberd/tls         # for custom tls certicates
  - /path/to/upload/files:/opt/ejabberd/upload    # for HTTP upload functionality
```
* path for module files is now also in the main `/opt/ejabberd/conf` and not anymore in a subfolder.
* variables `TLS_KEY_FILE_XMPP_DOMAIN*` & `TLS_CRT_FILE_XMPP_DOMAIN*` have been dropped. TLS certificates must be mounted as `*.pem`-files and will be referenced by the configuration script with a wildcard entry.
```
certfiles:
- /opt/ejabberd/tls/*.pem
```
* dhparam file is now located in `/opt/ejabberd/conf/dh.pem` directory and should be mounted here as well.

#### Changes
* `Docker secrets` are now supported by the configuration script for the following variables. Those should be mounted with readonly (`chmod 0400`) by ejabberd user:group `9000:9000`.
  * `LDAP_BIND_PW_FILE` for `LDAP_BIND_PW`
  * `DB_PASSWORD_FILE` for `DB_PASSWORD`
  * `REDIS_PASSWORD_FILE` for `REDIS_PASSWORD`
* Included `mod_host_meta` for https listener (with ejabberd version 22.05 or higher)
