#!/bin/bash +e
# catch signals as PID 1 in a container

# SIGNAL-handler
term_handler() {

  echo "terminating ssh ..."
  sudo /etc/init.d/ssh stop

  exit 143; # 128 + 15 -- SIGTERM
}

# on callback, stop all started processes in term_handler
trap 'kill ${!}; term_handler' SIGINT SIGKILL SIGTERM SIGQUIT SIGTSTP SIGSTOP SIGHUP

echo "starting ssh ..."
sudo /etc/init.d/ssh start

echo "starting openPLC ..."
cd /OpenPLC_v3
sudo ./start_openplc.sh

# wait forever not to exit the container
while true
do
  tail -f /dev/null & wait ${!}
done

exit 0
