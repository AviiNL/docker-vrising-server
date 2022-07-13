#!/bin/bash

term_handler() {
	kill -SIGTERM "$killpid"
	wait "$killpid" -f 2>/dev/null
	exit 143;
}

trap 'kill ${!}; term_handler' SIGTERM

chown -R steam:steam ${DATA_DIR}

# Run the server as steam user
su steam -c "${DATA_DIR}/scripts/start-server.sh" &
killpid="$!"

# Keep the process alive until the user presses Ctrl+C
while true
do
	wait $killpid
	exit 0;
done
