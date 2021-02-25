#!/bin/sh

set -eux

# Docker entrypoint (pid 1), run as root
[ "$1" = "mongod" ] || exec "$@" || exit $?

# 确保数据库归属于 mongodb 用户
[ "$(stat -c %U /data/db)" = mongodb ] || chown -R mongodb /data/db

: ${MONGO_USERNAME}
: ${MONGO_PASSWORD}

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

    # 创建 root 帐号
    mongo admin --eval \
        "db.createUser({
            user: '$MONGO_USERNAME',
            pwd: '$MONGO_PASSWORD',
            roles: [{role: 'root', db: 'admin'}]
        });"
    mongod --shutdown
fi

# 拷贝配置文件
if ! [ -f /etc/mongo/mongod.conf ]; then
    cp /mongod.conf /etc/mongo/
fi

cmd="$@"

# Drop root privilege (no way back), exec provided command as user mongodb
exec su -s /bin/sh -c "$cmd -f /etc/mongo/mongod.conf" mongodb