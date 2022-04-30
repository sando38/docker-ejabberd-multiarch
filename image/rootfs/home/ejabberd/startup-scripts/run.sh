#!/bin/bash
#set -x
START_POINT="$(date "+%Y.%m.%d-%H.%M.%S")"
echo ">>> ======================================================================="
echo ">>> ======================================================================="
echo ">>> "
echo ">>>       Starting ejabberd multiarch container with startup script"
echo ">>> "
echo ">>>                   It is $START_POINT"
echo ">>> "
echo ">>> ======================================================================="
echo ">>>   more infos at https://github.com/sando38/docker-ejabberd-multiarch"
echo ">>> ======================================================================="
echo ">>> "
echo ">>>       Start configuration"
echo ">>> "

# Clustering variables
set -m
EJABBERDCTL=$PATH_EJABBERD_HOME/bin/ejabberdctl
HOSTNAME_S=$(hostname -s) # ejabberd-0
HOSTNAME_F=$(hostname -f) # ejabberd-0.ejabberd.default.svc.cluster.local
HEADLESS_SERVICE="${HOSTNAME_F/$HOSTNAME_S./}" # ejabberd.default.svc.cluster.local
ERLANG_NODE_ARG="ejabberd@$HOSTNAME_F" # ejabberd@ejabberd-0.ejabberd.default.svc.cluster.local
ERLANG_NODE=$ERLANG_NODE_ARG

# Set ejabberd node name
echo ">>> Set ejabberd node name to ejabberd@$(hostname -s)"
echo ">>> "
sed -i -e "s/#ERLANG_NODE=ejabberd@localhost/ERLANG_NODE=ejabberd@$(hostname -f)/g" $PATH_EJABBERD_HOME/etc/ejabberd/ejabberdctl.cfg

# Set erlang cookie
echo ">>> Generating erlang cookie"
echo ">>> "
cat > $PATH_EJABBERD_HOME/.erlang.cookie <<EOF
${ERLANG_COOKIE:-$(openssl rand -hex 20)}
EOF
chmod 400 $PATH_EJABBERD_HOME/.erlang.cookie
echo ">>> "

# Dummy command ... easter egg
cat > abc.test <<EOF
abctest
EOF
rm abc.test
#
###
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
    $EJABBERDCTL -n $ERLANG_NODE_ARG start
    sleep 15s
    $EJABBERDCTL -n $ERLANG_NODE_ARG modules_update_specs
    if [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME ]; then
      echo ">>> installing $INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME"
      $EJABBERDCTL -n $ERLANG_NODE_ARG module_install $INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME
      cp $PATH_MODULE_CONFIG/$INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME.yml $PATH_EJABBERD_HOME/.ejabberd-modules/$INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME/conf/$INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME.yml
      echo ">>> "
    fi
    if [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME ]; then
      echo ">>> installing $INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME"
      $EJABBERDCTL -n $ERLANG_NODE_ARG module_install $INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME
      cp $PATH_MODULE_CONFIG/$INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME.yml $PATH_EJABBERD_HOME/.ejabberd-modules/$INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME/conf/$INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME.yml
      echo ">>> "
    fi
    if [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME ]; then
      echo ">>> installing $INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME"
      $EJABBERDCTL -n $ERLANG_NODE_ARG module_install $INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME
      cp $PATH_MODULE_CONFIG/$INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME.yml $PATH_EJABBERD_HOME/.ejabberd-modules/$INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME/conf/$INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME.yml
      echo ">>> "
    fi
    $EJABBERDCTL -n $ERLANG_NODE_ARG stop
    sleep 10s
# starting ejabberd
else
    echo ">>> ejabberd.yml configuration file found"
    echo ">>> No additional contribution modules shall be installed."
    echo ">>> "
fi

# change file permissions https://docs.ejabberd.im/admin/guide/security/#securing-sensitive-files
echo ">>> "
echo ">>> Changing file permissions to ejabberd user read/ write only"
echo ">>> "
echo ">>> Note: mounted volumes must be specified directly with volumeMount options"
echo ">>>       script cannot handle readonly volume mounts"
echo ""
## ejabberd configuration
find $PATH_EJABBERD_HOME/etc/ejabberd -type d -exec chmod 750 {} +
find $PATH_EJABBERD_HOME/etc/ejabberd -type f -exec chmod 640 {} +
## ejabberd database spool files
find $PATH_EJABBERD_HOME/var/lib/ejabberd -type d -exec chmod 750 {} +
find $PATH_EJABBERD_HOME/var/lib/ejabberd -type f -exec chmod 640 {} +
## ejabberd http file server
find $PATH_EJABBERD_HOME/files -type d -exec chmod 750 {} +
find $PATH_EJABBERD_HOME/files -type f -exec chmod 640 {} +
## ejabberd http upload
find $PATH_EJABBERD_HOME/upload -type d -exec chmod 750 {} +
find $PATH_EJABBERD_HOME/upload -type f -exec chmod 640 {} +
## ejabberd service log
find $PATH_EJABBERD_HOME/var/log/ejabberd -type d -exec chmod 750 {} +
find $PATH_EJABBERD_HOME/var/log/ejabberd -type f -exec chmod 640 {} +
## ejabberd TLS files
find $PATH_EJABBERD_HOME/tls -type d -exec chmod 750 {} +
find $PATH_EJABBERD_HOME/tls -type f -exec chmod 640 {} +
#
echo ""
echo ">>> finished changing file permissions"
echo ">>> "

# Cluster setup for kubernetes statefulset w/ headless service
if [ "${KUBERNETES_AUTO_CLUSTER:-false}" = true ]; then

  echo ">>> ======================================================================="
  echo ">>> "
  echo ">>> "
  echo ">>> Check and try to join cluster"
  echo ">>>     @ $HEADLESS_SERVICE"
  echo ">>> "

  # cluster IPs behind headless service
  IPS=$(nslookup $HEADLESS_SERVICE | tail -n +3 | grep "Address:" | sed -E 's/^Address: (.*)$/\1/')
  for IP in ${IPS}
  do
      echo ">>>"
      echo ">>> available ip addresses:"
      echo ""
      echo "$IPS"
      echo ""
      echo ">>> looking up hostname for: $IP"
      echo ">>>"
  #    HOSTNAME=$(nslookup $IP | tail -n +3 | grep -E '[^=]*= (.*).'"$HEADLESS_SERVICE"'$'  | sed -E 's/[^=]*= (.*).'"$HEADLESS_SERVICE"'$/\1/')
      HOSTNAME=$(nslookup $IP | grep -E '[^=]*= (.*).'"$HEADLESS_SERVICE" | sed -E 's/[^=]*= (.*).'"$HEADLESS_SERVICE"'/\1/' | sed -e 's/\.//g')
      if [[ "$HOSTNAME_S" == "$HOSTNAME" ]] ; then
          echo ">>> found own hostname, skipping"
          echo ">>>"
          continue
      fi
      $EJABBERDCTL -n $ERLANG_NODE_ARG start
      $EJABBERDCTL -n $ERLANG_NODE_ARG started
      echo ">>>"
      echo ">>> trying to connect to node with hostname"
      echo ">>> $HOSTNAME"
      echo ">>>"
      $EJABBERDCTL -n $ERLANG_NODE_ARG join_cluster "ejabberd@$HOSTNAME.$HEADLESS_SERVICE"
      CLUSTERING_RESULT=$?
      echo ">>>"
      echo "List of current cluster members:"
      echo ""
      $EJABBERDCTL -n $ERLANG_NODE_ARG list_cluster
      echo ""
      echo ">>>"
      $EJABBERDCTL -n $ERLANG_NODE_ARG stop
      if [[ $? -eq 0 ]] ; then
          echo ">>> successfully joined";
          echo ">>>"
          sleep 10s
          break
      else
          echo ">>> failed to join, trying next";
      fi
  done
fi

#Define cleanup procedure
cleanup() {
    echo ">>> Container stopped, performing cleanup..."
    $EJABBERDCTL -n $ERLANG_NODE_ARG leave_cluster "$ERLANG_NODE_ARG"
    $EJABBERDCTL -n $ERLANG_NODE_ARG stop
}

#Trap SIGTERM
trap 'cleanup' SIGTERM
#trap 'cleanup' TERM # 'SIG' before 'TERM' not working, -> 'sh' does not understand it
echo ">>> ======================================================================="
echo ">>> "
#echo ">>>       Time consumed to prepare: $CONFIGURATION_LENGTH"
echo ">>> "
echo ">>>       Launching ejabberd@$(hostname -s) in foreground"
echo ">>> "
echo ">>> "

# launching in foreground mode
$EJABBERDCTL -n $ERLANG_NODE_ARG foreground &

#Wait
wait $!
