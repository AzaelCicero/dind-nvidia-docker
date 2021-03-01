#!/bin/bash
set -eu

echo "Explicitly remove Containerd's default PID file to ensure that it can start properly if it was stopped uncleanly (and thus didn't clean up the PID file)"
find /run /var/run -iname 'containerd*.pid' -delete || :

echo "Launching dockerd..."
dockerd-entrypoint.sh &

echo "Waiting for Docker deamon to start..."
while : ; do
    sleep 1
    docker ps || continue
    break
done

echo "Everything ready lets ROCK..."

# If no command is provided, set bash to start interactive shell
if [ -z "$@" ]; then
    set - "bash" -l
fi

exec "$@"
