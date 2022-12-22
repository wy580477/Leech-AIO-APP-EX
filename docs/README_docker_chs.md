[概述](#概述)

[部署方式](#部署方式)

[初次使用](#初次使用)  

[更多用法和注意事项](#更多用法和注意事项)  

## 概述

本项目集成了yt-dlp和其Web前端metube、gallery-dl、Aria2+Rclone+qBittorrent+WebUI、pyLoad下载管理器、Rclone联动自动上传功能、Rclone远程存储文件列表和Webdav服务、Filebrowser轻量网盘。支持 Telegram 任务完成通知。

 1. 联动上传功能只需要准备rclone.conf配置文件, 其他一切配置都预备齐全。
 2. AMD64/Arm64架构支持，Lite版本增加Armv7支持。
 3. 可以从OliveTin网页端执行预定义yt-dlp、gallery-dl和Rclone指令。
 4. Rclone以daemon方式运行，可在WebUI上手动传输文件和实时监测传输情况。
 5. Aria2、qBittorrent和Rclone可以接入AriaNg/RcloneNg等前端面板、Aria2/qBit 电报机器人以及flexget/Radarr/Sonarr等应用。
 6. 基于 [runit](http://smarden.org/runit/index.html) 的进程管理，每个服务可以独立启停。
 7. log目录下有每个服务独立日志。

## 部署方式

 1. 下载[docker-compose文件](https://github.com/wy580477/Leech-AIO-APP-EX/blob/docker/docker-compose.yml). Lite版本无pyLoad，容器体积更小。
 2. 按说明设置好变量，用如下命令运行容器。

        docker-compose up -d

### 初次使用

1. 访问ip地址或域名+基础URL即可打开导航页。
2. 点击AriaNg，这时会弹出认证失败警告，按下图把之前部署时设置的密码填入RPC密钥，并检查协议和端口是否与浏览器地址栏显示的相符。
       <img src="https://user-images.githubusercontent.com/98247050/163184113-d0f09e78-01f9-4d4a-87b9-f4a9c1218253.png"  width="700"/>
3. 点击qBittorrent或者VueTorrent，输入默认用户名admin和默认密码adminadmin登陆。然后更改用户名和密码，务必设置为强密码。

   如果qBittorrent无法使用默认账户密码登陆，通过Filebrowser删除config/qBittorrent/config/qBittorrent.conf文件，然后在宿主机终端下执行下面命令：
```
       docker exec allinone sv restart qBittorrent
```  
4. 注意，无法通过Rclone Web前端建立需要网页认证的存储配置。需要通过Filebrowse将rclone.conf文件上传到config目录，可以通过编辑script.conf文件更改Rclone自动上传设置。
5. 如果升级版本后在script.conf文件中没有找到相关新增功能设置，参考最新版 [script.conf](https://github.com/wy580477/Leech-AIO-APP-EX/blob/docker/content/script.conf) 文件，自行添加缺失的设置选项。

### 更多用法和注意事项

 1. Telegram通知功能，需要在Telegram内与@BotFather对话注册bot。然后获取自己账户的ChatID或者bot加入的频道ChatID。具体详细步骤请Google。
 
    然后编辑config/script.conf文件，将botid:token和ChatID填入对应选项，通知功能即生效。
    
 2. metube可以在config/metube.conf配置文件中设置代理，示例:
```
       YTDL_OPTIONS="{\"postprocessors\":[{\"key\":\"Exec\",\"exec_cmd\":\"ytdlptorclone.sh\"}],\"proxy\":\"socks5://127.0.0.1:10808\",\"noprogress\":true}"
```
 3. 命令行调用yt-dlp和gallery-dl方法：

        docker exec allinone yt-dlp
        # 内置快捷脚本：dlpr  
        docker exec allinone dlpr https://www.youtube.com/watch?v=rbDzVzBsbGM
        # 下载到videos目录并与rclone联动

        docker exec allinone gallery-dl
        # 内置快捷脚本：gdlr
        docker exec allinone gdlr https://www.reddit.com/r/aww/comments/vb14vy/urgent_baby_flamingo_doing_flamingo_leg/
        # 下载到gallery_dl_downloads目录并与rclone联动

 4. 对于不支持qBittorrent自定义路径的应用, 在config/caddy目录下的Caddyfile文件中找到下列内容，去除每行开头的注释符号“#”:


            handle /api* {       
                    reverse_proxy * localhost:61804
            }

    然后在宿主机终端执行如下命令即可生效:

            docker exec allinone sv restart caddy

 5. Aria2 JSON-RPC 路径为： \${GLOBAL_PORTAL_PATH}/jsonrpc     
    Aria2 XML-RPC 路径为： \${GLOBAL_PORTAL_PATH}/rpc
 6. 考虑安全原因Filebrowser初始用户无管理员权限，如需要管理员权限，执行下列命令：


        docker exec -it allinone sh
        # 进入容器shell
        sv stop filebrowser
        # 停止filebrowser服务
        filebrowser -d /mnt/data/config/filebrowser.db users add 用户名 密码 --perm.admin
        # 新建管理员用户。也可以使用users update 用户名 --perm.admin命令赋予现有用户管理员权限。
        sv start filebrowser
        # 启动filebrowser服务

 7. pyLoad已知Bug：
    - 登陆后重定向到http，解决方法：关闭当前pyLoad页面，重新打开。
    - 解压后不能删除原文件，解决方法：Settings--Plugins--ExtractArchive，将"Move to trash instead delete"项设置为off。
 8. 将下列内容添加到rclone.conf文件，可以将本地存储作为Rclone的远程存储，便于在Rclone WebUI上手动上传。

        [local]
        type = alias
        remote = /mnt/data
