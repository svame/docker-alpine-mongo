# svame/alpine-mongo

这是个部署了 MongoDB 的 Alpine 版 Docker 镜像。此镜像将在运行时，通过环境变量设置用户名和密码，并默认启用 "--auth" 授权模式。

## 一、环境变量

### 变量说明：

- **MONGO_USERNAME**

  默认为 "root"，mongod 实例的 root 帐号名称。

- **MONGO_PASSWORD**

  默认为 "root"，mongod 实例的 root 帐号密码。

### 配置文件 env-file：

```shell
MONGO_USERNAME=root
MONGO_PASSWORD=root
```

## 二、使用说明

#### 拉取镜像：

```shell
docker pull svame/alpine-mongo
```

#### 运行 mongod：

可以直接使用默认的帐号密码：

```shell
# 创建工作目录
WORK_DIR=~/docker/mongo
mkdir -p $WORK_DIR

docker run -d \
  --restart=unless-stopped \
  --name mongo \
  -p 27017:27017 \
  -v $WORK_DIR/data:/data/db \
  -v $WORK_DIR/etc:/etc/mongo \
  -v $WORK_DIR/logs:/var/log/mongo \
  svame/alpine-mongo
```

也可以指定帐号密码：

```shell
# 创建工作目录
WORK_DIR=~/docker/mongo
mkdir -p $WORK_DIR

docker run -d \
  --restart=unless-stopped \
  --name mongo \
  -p 27017:27017 \
  -v $WORK_DIR/data:/data/db \
  -v $WORK_DIR/etc:/etc/mongo \
  -v $WORK_DIR/logs:/var/log/mongo \
  -e MONGO_USERNAME=root \
  -e MONGO_PASSWORD=root \
  svame/alpine-mongo
```

或者使用配置文件 env-file 来设置帐号密码：

```shell
# 创建工作目录
WORK_DIR=~/docker/mongo
mkdir -p $WORK_DIR

docker run -d \
  --restart=unless-stopped \
  --name mongo \
  --env-file env-file \
  -p 27017:27017 \
  -v $WORK_DIR/data:/data/db \
  -v $WORK_DIR/etc:/etc/mongo \
  -v $WORK_DIR/logs:/var/log/mongo \
  svame/alpine-mongo
```

### 三、重新构建

如果想重新构建镜像，需要拷贝这些文件到本地：

- Dockerfile
- entrypoint.sh
- mongod.conf
- build.sh
- version
- run.sh

修改 build.sh 和 run.sh 可执行权限：

```shell
chmod u+x build.sh run.sh
```

然后执行镜像构建脚本：

```shell
./build.sh
```

构建完成后，查看当前镜像列表，会看到一个名为 svame/alpine-mongo 的镜像：

```shell
docker images
```

接着运行容器：

```shell
./run.sh
```

查看当前容器列表，会看到一个名为 mongo 的容器：

```shell
docker ps -a
```

容器启动时会做以下这些动作：

- 创建 mongo 帐号 root
- 加载配置文件：`~/docker/mongo/etc/mongod.conf`
- 创建数据目录：`~/docker/mongo/data`
- 创建日志目录：`~/docker/mongo/logs`

可以执行 mongo shell 查看帐号是否创建成功：

```shell
docker exec -it mongo mongo
> use admin
> db.auth('root', 'root')
> show users
```
