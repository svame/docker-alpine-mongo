#!/bin/sh

set -eux

# Docker entrypoint (pid 1), run as root
[ "$1" = "mongod" ] || exec "$@" || exit $?

# Make sure that database is owned by user mongodb
[ "$(stat -c %U /data/db)" = mongodb ] || chown -R mongodb /data/db

: ${MONGO_ROOT_USERNAME}
: ${MONGO_ROOT_PASSWORD}
: ${MONGO_ADMIN_USERNAME}
: ${MONGO_ADMIN_PASSWORD}

if ! [ -f /data/db/mongo_initialized ]; then
    echo "Used by svame/alpine-mongo docker container." > /data/db/mongo_initialized
    echo "DO NOT DELETE!" >> /data/db/mongo_initialized

    eval su -s /bin/sh -c "mongod" mongodb &

    RET=1
    while [ $RET -ne 0 ]; do
        sleep 3
        mongo admin --eval "help" >/dev/null 2>&1
        RET=$?
    done

    # set root user
    mongo admin --eval \
        "db.createUser({
            user: '$MONGO_ROOT_USERNAME',
            pwd: '$MONGO_ROOT_PASSWORD',
            roles: [{role: 'root', db: 'admin'}]
        });
        db.createUser({
            user: '$MONGO_ADMIN_USERNAME',
            pwd: '$MONGO_ADMIN_PASSWORD',
            roles: [{role: 'userAdminAnyDatabase', db: 'admin'}]
        });"

    mongod --shutdown
fi

cmd="$@"

# Drop root privilege (no way back), exec provided command as user mongodb
#cmd=exec; for i; do cmd="$cmd '$i'"; done

exec su -s /bin/sh -c "$cmd -f /etc/mongo/mongod.conf" mongodb
