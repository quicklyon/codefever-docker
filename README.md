<!-- 该文档是模板生成，手动修改的内容会被覆盖，详情参见：https://github.com/quicklyon/template-toolkit -->
# QuickOn codefever 应用镜像

[![GitHub Workflow Status](https://github.com/quicklyon/codefever-docker/actions/workflows/docker.yml/badge.svg)](https://github.com/quicklyon/codefever-docker/actions/workflows/docker.yml)
![Docker Pulls](https://img.shields.io/docker/pulls/easysoft/codefever?style=flat-square)
![Docker Image Size](https://img.shields.io/docker/image-size/easysoft/codefever?style=flat-square)
![GitHub tag](https://img.shields.io/github/v/tag/quicklyon/codefever-docker?style=flat-square)

> 申明: 该软件镜像是由QuickOn打包。在发行中提及的各自商标由各自的公司或个人所有，使用它们并不意味着任何从属关系。

## 快速参考

- 通过 [渠成软件百宝箱](https://www.qucheng.com/app-install/codefever-install-1.html) 一键安装 **codefever**
- [Dockerfile 源码](https://github.com/quicklyon/codefever-docker)
- [codefever 源码](https://github.com/PGYER/codefever)
- [codefever 官网](https://codefever.cn/)

## 一、关于 codefever

[CodeFever](https://codefever.cn) 是完全免费开源的 Git 代码托管服务，支持一行命令安装到自己服务器！

![screenshots](https://raw.githubusercontent.com/quicklyon/codefever-docker/master/.template/screenshot.png)

codefever官网：[https://codefever.cn/](https://codefever.cn/)

### **功能特性**

- 🆓 **永久免费:** 永久免费提供给大家使用，您无需担心付费
- ❤️ **完整开源:** 毫无保留的完整开源，无任何编译或加密代码
- 🥬 **轻量安装:** 极简设计风格，排除重度冗余的多余功能
- ⚡️ **性能高效:** 速度极快，对服务器资源要求极低，1核CPU/1G内存即可运行
- ♾️ **无限仓库:** 没有任何仓库数量、使用数量的限制
- ⌨️ **代码对比:** 支持提交代码的不同版本支持高亮显示对比
- 🛤️ **分支管理:** 完整支持 Git 原生分支和 Tag，帮助更清晰的管理代码
- 🙋‍♂️ **合并请求（Merge Request）:** 支持多人协作，让代码版本控制更顺畅
- 🙅🏻‍♀️ **分支保护:** 分支保护功能让代码提交安全可控，代码 Review 更容易清晰
- 👥 **多人协作:** 支持多人团队协作，并可以设置每个成员的角色和权限
- 🔌 **Webhook:** 支持Webhook功能，可轻松和其他系统进行集成
- 🖥️ **管理后台:** 支持超级管理员后台，可以让团队leader管理所有项目和用户信息
- 💬 **中英双语:** 原生支持中文和英文两种语言

## 二、支持的版本(Tag)

由于版本比较多,这里只列出最新的5个版本,更详细的版本列表请参考:[可用版本列表](https://hub.docker.com/r/easysoft/codefever/tags/)

<!-- 这里是镜像的【Tag】信息，通过命令维护，详情参考：https://github.com/quicklyon/template-toolkit -->

## 三、获取镜像

推荐从 [Docker Hub Registry](https://hub.docker.com/r/easysoft/codefever) 拉取我们构建好的官方Docker镜像。

```bash
docker pull easysoft/codefever:latest
```

如需使用指定的版本,可以拉取一个包含版本标签的镜像,在Docker Hub仓库中查看 [可用版本列表](https://hub.docker.com/r/easysoft/codefever/tags/)

```bash
docker pull easysoft/codefever:[TAG]
```

## 四、持久化数据

如果你删除容器，所有的数据都将被删除，下次运行镜像时会重新初始化数据。为了避免数据丢失，你应该为容器提供一个挂在卷，这样可以将数据进行持久化存储。

为了数据持久化，你应该挂载持久化目录：

- /data 持久化数据

如果挂载的目录为空，首次启动会自动初始化相关文件

```bash
$ docker run -it \
    -v $PWD/data:/data \
docker pull easysoft/codefever:latest
```

或者修改 docker-compose.yml 文件，添加持久化目录配置

```bash
services:
  codefever:
  ...
    volumes:
      - /path/to/persistence:/data
  ...
```

## 五、环境变量

| 变量名           | 默认值               | 说明                      |
| ---------------- | ------------------- | ------------------------- |
| EASYSOFT_DEBUG   | false               | 是否打开调试信息，默认关闭   |
| DB_HOST          | 127.0.0.1           | MySQL 主机地址             |
| DB_PORT          | 3306                | MySQL 端口                 |
| DB_NAME          | codefever_community | 数据库名称                 |
| DB_USER          | root                | MySQL 用户名               |
| DB_PASSWORD      | pass4Quick0n        | MySQL 密码                 |

## 六、运行

### 6.1 单机Docker-compose方式运行

```bash
# 启动服务
make run

# 查看服务状态
make ps

# 查看服务日志
docker-compose logs -f codefever

```

**说明:**

- 启动成功后，打开浏览器输入 `http://<你的IP>:18080` 访问管理后台
- 默认用户名：`root@codefever.cn`，默认密码：`123456`
- [VERSION](https://github.com/quicklyon/codefever-docker/blob/master/VERSION) 文件中详细的定义了Makefile可以操作的版本
- [docker-compose.yml](https://github.com/quicklyon/codefever-docker/blob/master/docker-compose.yml)

## 七、版本升级

<!-- 这里是镜像的【版本升级】信息，通过命令维护，详情参考：https://github.com/quicklyon/template-toolkit -->
