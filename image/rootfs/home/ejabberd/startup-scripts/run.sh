#!/bin/sh
#set -x
echo ">>> ======================================================================="
echo ">>> ======================================================================="
echo ">>> "
echo ">>>       Starting ejabberd multiarch container with startup script"
echo ">>> "
echo ">>> ======================================================================="
echo ">>>   more infos at https://github.com/sando38/docker-ejabberd-multiarch"
echo ">>> ======================================================================="
echo ">>> "
echo ">>>       Start configuration"
echo ">>> "

# Apply environment variables settings
#sed -i -e "s/<APC_SHM_SIZE>/$APC_SHM_SIZE/g" /usr/local/etc/php/conf.d/apcu.ini \
#       -e "s/<MEMORY_LIMIT>/$MEMORY_LIMIT/g" /usr/local/etc/php-fpm.conf

# Set ejabberd node name
echo ">>> Set ejabberd node name to ejabberd@$(hostname -s)"
echo ">>> "
sed -i -e "s/#ERLANG_NODE=ejabberd@localhost/ERLANG_NODE=ejabberd@$(hostname -s)/g" $PATH_EJABBERD_HOME/etc/ejabberd/ejabberdctl.cfg

# If new install, run setup
if [ ! -f $PATH_EJABBERD_HOME/etc/ejabberd/ejabberd.yml ]; then
    echo ">>> no ejabberd.yml configuration file in directory $PATH_EJABBERD_HOME/etc/ejabberd found,"
    echo ">>> creating initial configuration from environment variables"
    echo ">>> "
    $PATH_STARTUP_SCRIPTS/setup.sh
# checking if additional modules shall be installed
elif [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME ] || [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME ] || [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME ]; then
    echo ">>> ejabberd.yml configuration file found"
    echo ">>> Starting ejabberd@$(hostname -s) to install and activate contribution modules"
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
    $PATH_EJABBERD_HOME/bin/ejabberdctl stop
    sleep 10s
# starting ejabberd
else
    echo ">>> ejabberd.yml configuration file found"
    echo ">>> No additional contribution modules shall be installed."
    echo ">>> "
fi

#set +x
#Define cleanup procedure
cleanup() {
    echo ">>> "
    echo ">>> Container stopped, performing cleanup..."
    echo ">>> "
    $PATH_EJABBERD_HOME/bin/ejabberdctl stop
}
#Trap SIGTERM
trap 'cleanup' TERM # 'SIG' before 'TERM' not working, -> 'sh' does not understand it
echo ">>> ======================================================================="
echo ">>> "
echo ">>>       Launching ejabberd@$(hostname -s) in foreground"
echo ">>> "
echo ">>> "
$PATH_EJABBERD_HOME/bin/ejabberdctl foreground &
#Wait
wait $!
