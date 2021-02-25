FROM alpine:3.9

# 默认的 root 和 admin 帐号密码，可在 run 容器时加 --env-file 指定
ENV MONGO_ROOT_USERNAME root
ENV MONGO_ROOT_PASSWORD root
ENV MONGO_ADMIN_USERNAME admin
ENV MONGO_ADMIN_PASSWORD admin

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

COPY entrypoint.sh /entrypoint.sh
COPY mongod.conf /etc/mongo/mongod.conf

VOLUME /data/db

EXPOSE 27017 28017

ENTRYPOINT ["/entrypoint.sh"]
CMD ["mongod", "--bind_ip_all"]
