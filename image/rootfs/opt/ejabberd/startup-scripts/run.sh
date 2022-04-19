#!/bin/sh
set -x
# Apply environment variables settings
#sed -i -e "s/<APC_SHM_SIZE>/$APC_SHM_SIZE/g" /usr/local/etc/php/conf.d/apcu.ini \
#       -e "s/<MEMORY_LIMIT>/$MEMORY_LIMIT/g" /usr/local/etc/php-fpm.conf

# If new install, run setup
if [ ! -f $PATH_EJABBERD_HOME/etc/ejabberd/ejabberd.yml ]; then
    echo "no configuration found, creating initial configuration from environment variables"
    $PATH_STARTUP_SCRIPTS/setup.sh
else
    echo "starting ejabberd in foreground mode"
fi

# Run processes
$PATH_EJABBERD_HOME/bin/ejabberdctl foreground
sleep infinity
