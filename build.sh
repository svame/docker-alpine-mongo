#! /bin/bash

set -eux

# 获取版本号
SRC_DIR=$(cd `dirname $0`; pwd)
version=$(cat $SRC_DIR/version)

docker build -t svame/alpine-mongo:$version .
