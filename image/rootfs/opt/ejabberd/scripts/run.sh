#!/bin/sh
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
#set -m
EJABBERDCTL=$HOME/scripts/ejabberdctl
HOSTNAME_S=$(hostname -s) # ejabberd-0
HOSTNAME_F=$(hostname -f) # ejabberd-0.ejabberd.default.svc.cluster.local
HEADLESS_SERVICE="${HOSTNAME_F/$HOSTNAME_S./}" # ejabberd.default.svc.cluster.local
ERLANG_NODE_ARG="ejabberd@$HOSTNAME_F" # ejabberd@ejabberd-0.ejabberd.default.svc.cluster.local
ERLANG_NODE=$ERLANG_NODE_ARG
# Set ejabberd node name
echo ">>> Set ejabberd node name to $ERLANG_NODE_ARG"
echo ">>> "
#sed -i -e "s/ERLANG_NODE_ARG=ejabberd@localhost/ERLANG_NODE_ARG=ejabberd@$(hostname -f)/g" $EJABBERDCTL
# Set erlang cookie
#ERLANG_COOKIE=$(openssl rand -hex 40)
if [ -n "$ERLANG_COOKIE" ] && [ ! -f $HOME/.erlang.cookie ]; then
  echo ">>> Generating erlang cookie from ERLANG_COOKIE"
  echo ">>> in case of error the default cookie from installation will be used"
  echo ""
  echo $ERLANG_COOKIE > $HOME/.erlang.cookie
  chmod 400 $HOME/.erlang.cookie
  echo ""
  echo ">>> "
elif [ -n "$ERLANG_COOKIE" ] && [ -f $HOME/.erlang.cookie ]; then
  # make check that ERLANG_COOKIE and $HOME/.erlang.cookie have same value
  if [ "$ERLANG_COOKIE" = "$(cat $HOME/.erlang.cookie)" ]; then
    echo ">>> Using existing $HOME/.erlang.cookie file and variable ERLANG_COOKIE"
    echo ">>> "
  else
    echo ">>> $HOME/.erlang.cookie file and variable ERLANG_COOKIE do not match"
    echo ">>> override ERLANG_COOKIE variable from $HOME/.erlang.cookie file"
    export ERLANG_COOKIE=$(cat $HOME/.erlang.cookie)
    echo ">>> "
  fi
elif [ -z "$ERLANG_COOKIE" ] && [ -f $HOME/.erlang.cookie ]; then
  echo ">>> Using existing $HOME/.erlang.cookie file"
  echo ">>> creating ERLANG_COOKIE variable"
  export ERLANG_COOKIE=$(cat $HOME/.erlang.cookie)
  echo ">>> "
elif [ -z "$ERLANG_COOKIE" ]; then
  echo ">>> Generating random erlang cookie"
  echo ">>> Clustering will not work"
  echo ""
  export ERLANG_COOKIE=$(openssl rand -hex 40)
  echo $ERLANG_COOKIE > $HOME/.erlang.cookie
  chmod 400 $HOME/.erlang.cookie
  echo ""
  echo ">>> in case of error the default cookie from installation will be used"
  echo ">>> please consider setting ERLANG_COOKIE, especially if you want to cluster,"
  echo ">>> and secure erlang ports to restrict access"
  echo ">>> "
fi
#
###
# If new install, run setup
if [ ! -f $HOME/conf/ejabberd.yml ]; then
    echo ">>> no ejabberd.yml configuration file in directory $HOME/conf found,"
    echo ">>> creating initial configuration from environment variables"
    echo ">>> "
    /usr/local/bin/setup.sh
# checking if additional modules shall be installed
elif [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME ] \
     || [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME ] \
     || [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME ]; then
    echo ">>> ejabberd.yml configuration file found"
    echo ">>> Starting ejabberd@$(hostname -s) to install and activate contribution modules"
    echo ">>> "
    $EJABBERDCTL -n $ERLANG_NODE_ARG start
    sleep 15s
    $EJABBERDCTL -n $ERLANG_NODE_ARG modules_update_specs
    if [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME ]; then
      echo ">>> installing $INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME"
      $EJABBERDCTL -n $ERLANG_NODE_ARG module_install $INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME
      cp $HOME/conf/$INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME.yml $HOME/.ejabberd-modules/$INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME/conf/$INSTALL_ADDITIONAL_NON_CORE_MODULE_1_NAME.yml
      echo ">>> "
    fi
    if [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME ]; then
      echo ">>> installing $INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME"
      $EJABBERDCTL -n $ERLANG_NODE_ARG module_install $INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME
      cp $HOME/conf/$INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME.yml $HOME/.ejabberd-modules/$INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME/conf/$INSTALL_ADDITIONAL_NON_CORE_MODULE_2_NAME.yml
      echo ">>> "
    fi
    if [ ! -z $INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME ]; then
      echo ">>> installing $INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME"
      $EJABBERDCTL -n $ERLANG_NODE_ARG module_install $INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME
      cp $HOME/conf/$INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME.yml $HOME/.ejabberd-modules/$INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME/conf/$INSTALL_ADDITIONAL_NON_CORE_MODULE_3_NAME.yml
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
find $HOME/conf -type d -exec chmod 750 {} +
find $HOME/conf -type f -exec chmod 640 {} +
## ejabberd database spool files
find $HOME/database -type d -exec chmod 750 {} +
find $HOME/database -type f -exec chmod 640 {} +
## ejabberd http file server
find $HOME/files -type d -exec chmod 750 {} +
find $HOME/files -type f -exec chmod 640 {} +
## ejabberd http upload
find $HOME/upload -type d -exec chmod 750 {} +
find $HOME/upload -type f -exec chmod 640 {} +
## ejabberd logs
find $HOME/logs -type d -exec chmod 750 {} +
find $HOME/logs -type f -exec chmod 640 {} +
## ejabberd TLS files
find $HOME/tls -type d -exec chmod 750 {} +
find $HOME/tls -type f -exec chmod 640 {} +
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
  IPS=$(getent hosts $HEADLESS_SERVICE | awk '{ print $1 }')
  for IP in ${IPS}
  do
      echo ">>>"
      echo ">>> available ip addresses:"
      echo ""
      echo "$IPS"
      echo ""
      echo ">>> looking up hostname for: $IP"
      echo ">>>"
      HOSTNAME=$(getent hosts $IP | awk '{ print $2 }')
      if [[ "$HOSTNAME_F" == "$HOSTNAME" ]] ; then
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
      $EJABBERDCTL -n $ERLANG_NODE_ARG join_cluster "ejabberd@$HOSTNAME"
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
