## 注意

 1. **请勿滥用，Colab账号封禁风险自负。**
 2. Aria2和qBittorrent配置文件默认限速5MB/s。

[概述](#概述)

[部署方式](#部署方式)

[初次使用](#初次使用)  

[更多用法和注意事项](#更多用法和注意事项)  

## 概述

本项目集成了yt-dlp、gallery-dl、Aria2+Rclone+qBittorrent+WebUI、pyLoad下载管理器、Rclone联动自动上传功能、Rclone远程存储文件列表、Filebrowser轻量网盘、OliveTin网页执行shell命令、ttyd Web终端。

 1. 联动上传功能只需要准备rclone.conf配置文件, 其他一切配置都预备齐全。
 2. Rclone以daemon方式运行，可在WebUI上手动传输文件和实时监测传输情况。
 3. 自动备份相关配置文件到Google Drive，实现了配置文件持久化。
 4. 可以从OliveTin网页端执行预定义yt-dlp、gallery-dl和Rclone指令。
 5. ttyd网页终端，可从命令行执行yt-dlp下载工具和其它命令。
 6. log目录下有每个服务独立日志。

## 部署方式

 1. 在Google Drive根目录下建立一个名为 <code>AIO_FILES</code> 的文件夹.
 2. 将 [main.zip](https://github.com/wy580477/Leech-AIO-APP-EX/archive/refs/heads/Colab.zip) 上传到 <code>AIO_FILES</code> 文件夹.
 3. 将 [AIO.ipynb](https://github.com/wy580477/Leech-AIO-APP-EX/raw/Colab/AIO.ipynb) 上传到Google Drive.
 4. 运行 AIO.ipynb.

### 初次使用

- 通过Filebrowse将rclone.conf文件上传到config目录，可以通过编辑script.conf文件更改Rclone自动上传设置。
- 将下列内容作为rclone.conf文件，可将Colab中挂载的Google Drive作为Rclone的远程存储。

      [local]
      type = alias
      remote = /content/drive/MyDrive

- yt-dlp和gallery-dl下载工具可以通过ttyd在网页终端执行。    
    内置快捷指令：  
    dlpr：使用yt-dlp下载视频到videos文件夹下，下载完成后发送任务到rclone。 
    gdlr：使用gallery-dl下载文件到gallery_dl_downloads文件夹下，下载完成后发送任务到rclone。  

### 更多用法和注意事项

 1. pyLoad已知Bug：
    - 登陆后重定向到http，解决方法：关闭当前pyLoad页面，重新打开。
    - 解压后不能删除原文件，解决方法：Settings--Plugins--ExtractArchive，将"Move to trash instead delete"项设置为off。
 2. 无法通过Rclone Web前端建立需要网页认证的存储配置。
