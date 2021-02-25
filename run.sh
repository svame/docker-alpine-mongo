#! /bin/bash

set -eu

# 获取版本号
SRC_DIR=$(cd `dirname $0`; pwd)
version=$(cat $SRC_DIR/version)

# 保证工作目录存在
WORK_DIR=~/docker/mongo
mkdir -p $WORK_DIR

echo "脚本目录：$SRC_DIR"
echo "工作目录：$WORK_DIR"
echo "帐号密码："
echo $(cat $SRC_DIR/env-file)

docker run -d \
  --name mongo \
  --restart=unless-stopped \
  --env-file $SRC_DIR/env-file \
  -p 27017:27017 \
  -v $WORK_DIR/data:/data/db \
  -v $WORK_DIR/etc:/etc/mongo \
  -v $WORK_DIR/logs:/var/log/mongo \
  svame/alpine-mongo:$version

docker logs mongo
