## 鸣谢

- [P3TERX/aria2.conf](https://github.com/P3TERX/aria2.conf)  依靠来自P3TERX的Aria2脚本，实现了Aria2下载完成自动触发Rclone上传。
- [wahyd4/aria2-ariang-docker](https://github.com/wahyd4/aria2-ariang-docker)  启发了本项目的总体思路。
- [bastienwirtz/homer](https://github.com/bastienwirtz/homer)  使用yaml配置文件的静态导航页，便于自定义。
- [mayswind/AriaNg](https://github.com/mayswind/AriaNg) | [filebrowser/filebrowser](https://github.com/filebrowser/filebrowser) | [aria2/aria2](https://github.com/aria2/aria2) | [rclone/rclone](https://github.com/rclone/rclone) | [yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp) | [userdocs/qbittorrent-nox-static](https://github.com/userdocs/qbittorrent-nox-static) | [WDaan/VueTorrent](https://github.com/WDaan/VueTorrent) | [alexta69/metube](https://github.com/alexta69/metube) | [pyload/pyload](https://github.com/pyload/pyload)

## 注意

- 所有可以登陆此APP的用户可以访问/修改此APP以及Rclone远程存储的所有数据，不要存放敏感数据，不要与他人共享使用。

[概述](#概述)

[部署方式](#部署方式)

[变量设置](#变量设置)  

[初次使用](#初次使用)  

[更多用法和注意事项](#更多用法和注意事项)  

## 概述

本项目集成了yt-dlp和其Web前端metube、Aria2+Rclone+qBittorrent+WebUI、pyLoad下载管理器、Rclone联动自动上传功能、、Rclone远程存储文件列表和Webdav服务、可自定义的导航页、Filebrowser轻量网盘。

[VPS部署版本](https://github.com/wy580477/Aria2-AIO-Container)

![image](https://user-images.githubusercontent.com/98247050/170441806-1d6fd4f4-d1e3-479f-9893-13f1a3e03433.png)

 1. 联动上传功能只需要准备rclone.conf配置文件, 其他一切配置都预备齐全。
 2. AMD64/Arm64架构支持。
 3. Rclone以daemon方式运行，可在WebUI上手动传输文件和实时监测传输情况。
 4. Aria2、qBittorrent和Rclone可以接入其它host上运行的AriaNg/RcloneNg等前端面板。
 5. log目录下有每个服务独立日志。

## 部署方式

 1. 下载[docker-compose文件](https://raw.githubusercontent.com/wy580477/Aria2-AIO-Container/master/docker-compose.yml)
 2. 按说明设置好变量，用如下命令运行容器。

        ```
        docker-compose up -d
        ```

### 初次使用

    1. 按ip地址或域名+基础URL即可打开导航页。
    2. 点击AriaNg，这时会弹出认证失败警告，按下图把之前部署时设置的密码填入RPC密钥即可。
          <img src="https://user-images.githubusercontent.com/98247050/163184113-d0f09e78-01f9-4d4a-87b9-f4a9c1218253.png"  width="700"/>
    3. 点击qBittorrent或者VueTorrent，输入默认用户名admin和默认密码adminadmin登陆。然后更改用户名和密码，务必设置为强密码。
    4. 通过Filebrowse将rclone.conf文件上传到config目录，可以通过编辑script.conf文件更改Rclone自动上传设置。

### 更多用法和注意事项

 1. 如果网页访问APP出现故障，按下shift+F5强制刷新，如果还不行，从浏览器中清除域名/ip缓存和cookie。
 2. 命令行调用yt-dlp方法：

        ```
        docker exec allinone yt-dlp
        # 内置快捷脚本：ytdlpup.sh  
        docker exec allinone yt-dlpup.sh https://www.youtube.com/watch?v=rbDzVzBsbGM
        # 下载到/mnt/data/videos目录并与rclone联动。注意要用容器内部路径，不是主机路径。
        ```

 3. 考虑安全原因Filebrowser初始用户无管理员权限，如需要管理员权限，执行下列命令：

        ```
        docker exec -it allinone sh
        # 进入容器shell
        sv stop filebrowser
        # 停止filebrowser服务
        filebrowser -d /mnt/config/filebrowser.db users add 用户名 密码 --perm.admin
        # 新建管理员用户。也可以使用users update 用户名 --perm.admin命令赋予现有用户管理员权限。
        sv start filebrowser
        # 启动filebrowser服务
        ```
 4. pyLoad已知Bug：
    - 登陆后重定向到http，解决方法：关闭当前pyLoad页面，重新打开。
    - 解压后不能删除原文件，解决方法：Settings--Plugins--ExtractArchive，将"Move to trash instead delete"项设置为off。
 5. 将下列内容添加到rclone.conf文件，可以将本地存储作为Rclone的远程存储，便于在Rclone WebUI上手动上传。

        ```
        [local]
        type = alias
        remote = /mnt/data
        ```

 6. 无法通过Rclone Web前端建立需要网页认证的存储配置。
