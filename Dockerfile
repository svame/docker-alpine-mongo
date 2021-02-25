FROM alpine:3.9

# 默认的 root 帐号密码，可在 run 容器时加 --env-file 指定
ENV MONGO_USERNAME root
ENV MONGO_PASSWORD root

# 使用国内镜像源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

# 设置中国时区，安装 mongodb
RUN set -eux \
  && apk update \
  && apk upgrade \
  && apk add --no-cache tzdata \
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone \
  && apk del tzdata \
  && apk add --no-cache mongodb

VOLUME /data/db
VOLUME /etc/mongo

COPY mongod.conf /mongod.conf
COPY entrypoint.sh /entrypoint.sh

EXPOSE 27017 28017

ENTRYPOINT ["/entrypoint.sh"]
CMD ["mongod", "--bind_ip_all"]
