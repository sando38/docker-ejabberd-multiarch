#!/bin/sh
set -x
# Apply environment variables settings
#sed -i -e "s/<APC_SHM_SIZE>/$APC_SHM_SIZE/g" /usr/local/etc/php/conf.d/apcu.ini \
#       -e "s/<MEMORY_LIMIT>/$MEMORY_LIMIT/g" /usr/local/etc/php-fpm.conf

# Set ejabberd node name
sed -i -e "s/#ERLANG_NODE=ejabberd@localhost/ERLANG_NODE=ejabberd@$(hostname -s)/g" $PATH_EJABBERD_HOME/etc/ejabberd/ejabberdctl.cfg

# If new install, run setup
if [ ! -f $PATH_EJABBERD_HOME/etc/ejabberd/ejabberd.yml ]; then
    echo "no configuration found, creating initial configuration from environment variables"
    $PATH_STARTUP_SCRIPTS/setup.sh
# checking if additional modules shall be installed
elif [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME ] || [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME ] || [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME ]; then
    echo "installing and activating contribution modules"
    $PATH_EJABBERD_HOME/bin/ejabberdctl start
    sleep 15s
    $PATH_EJABBERD_HOME/bin/ejabberdctl modules_update_specs
    if [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME ]; then
      $PATH_EJABBERD_HOME/bin/ejabberdctl module_install $INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME
      cp $PATH_MODULE_CONFIG/$INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME.yml $PATH_EJABBERD_HOME/.ejabberd-modules/$INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME/conf/$INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME.yml
    fi
    if [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME ]; then
      $PATH_EJABBERD_HOME/bin/ejabberdctl module_install $INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME
      cp $PATH_MODULE_CONFIG/$INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME.yml $PATH_EJABBERD_HOME/.ejabberd-modules/$INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME/conf/$INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME.yml
    fi
    if [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME ]; then
      $PATH_EJABBERD_HOME/bin/ejabberdctl module_install $INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME
      cp $PATH_MODULE_CONFIG/$INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME.yml $PATH_EJABBERD_HOME/.ejabberd-modules/$INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME/conf/$INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME.yml
    fi
    $PATH_EJABBERD_HOME/bin/ejabberdctl stop
    sleep 10s
# starting ejabberd
else
    echo "starting ejabberd in foreground mode"
fi

# Run processes
$PATH_EJABBERD_HOME/bin/ejabberdctl foreground
sleep infinity
