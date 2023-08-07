## 注意

### Doprax 已停止提供免费服务

 1. **请勿滥用，Doprax 账号封禁风险自负。**
 2. **占用大量硬盘空间可能导致账户被封禁。**
 3. 容器的文件系统是临时性的，除挂载到数据卷的 /mnt/data/config 目录，重启后会恢复到部署时状态。
 4. Aria2和qBittorrent配置文件默认限速5MB/s。
 5. 无法通过Rclone Web前端建立需要网页认证的存储配置。需要自行在其他设备上准备好rclone.conf文件。
 6. 不支持 Rclone mount。

[概述](#概述)

[部署方式](#部署方式)

[变量设置](#变量设置)  

[初次使用](#初次使用)  

[更多用法和注意事项](#更多用法和注意事项)  

## 概述

本项目集成了yt-dlp、gallery-dl、Aria2+Rclone+qBittorrent+WebUI、pyLoad下载管理器、Rclone联动自动上传功能、Rclone远程存储文件列表和Webdav服务、Filebrowser轻量网盘、OliveTin网页执行shell命令、ttyd Web终端、Telegram任务完成通知。

 1. 联动上传功能只需要准备rclone.conf配置文件, 其他一切配置都预备齐全。
 2. Rclone以daemon方式运行，可在WebUI上手动传输文件和实时监测传输情况。
 3. Aria2、qBittorrent和Rclone可以接入其它host上运行的AriaNg/RcloneNg等前端面板和flexget/Radarr/Sonarr等应用。
 4. 可以从OliveTin网页端执行yt-dlp、gallery-dl和Rclone指令。
 5. ttyd网页终端，可命令行执行yt-dlp下载工具和其它命令。
 6. 基于 [runit](http://smarden.org/runit/index.html) 的进程管理，每个服务可以独立启停。
 7. log目录下有每个服务独立日志。
 8. 集成 [NodeStatus](https://github.com/cokemine/nodestatus) 探针客户端。[NodeStatus 服务端](https://github.com/wy580477/NodeStatus-Docker)也可以部署在 PaaS 平台上。

## 部署方式

  **请勿使用本仓库直接部署**  

 1. 点击本仓库右上角Fork，取消选择"Copy the main branch only"，再点击Create Fork。
 2. 在Fork出来的仓库页面上点击Setting，勾选Template repository。
 3. 然后点击Code返回之前的页面，点Setting下面新出现的按钮Use this template，起个随机名字创建新库。
 4. 在你新建立的Github仓库页面上点击Setting，再点击Branches，将默认分支改为doprax。

     <details>
    <summary>截图</summary>

    ![avatar](/screenshots/branch.png)

    </details>

 4. 前往 Doprax 网站管理面板，点击"Account"，再点击"Connect to Github"，连接你的 github 账号。
 5. 点击"Dashboard"，再点击"New app"，建立一个新 app。
 6. 点击你刚建立的 app，再点击"Import from my Github account"，然后选择你刚建立的 Github 仓库导入。
 7. 点击"Add environment variable"，按下文变量设置部分的说明设置变量。
 8. 点击"Volume", 建立一个新的数据卷（volume）并将其挂载到 /mnt/data/config.
 
    <details>
    <summary>截图</summary>

    ![avatar](/screenshots/volume.png)

    </details>
 9. 点击"Deploy", 再点击"Resources". 将 RAM 设置为 512MB, 点击 "Submit". 然后点击开始按钮并等待部署完成。
    <details>
    <summary>截图</summary>

    ![avatar](/screenshots/deploy.png)

    </details>

## 变量设置

对部署时可设定的变量做如下说明。
| 变量 | 默认值 | 说明 |
| :--- | :--- | :--- |
| `GLOBAL_USER` | admin | 用户名，适用于除qBittorrent外所有需要输入用户名的Web服务 |
| `GLOBAL_PASSWORD` | password | 务必修改为强密码，同样适用于除qBittorrent外所有需要输入密码的Web服务，同时也是Aria2 RPC密钥。 |
| `GLOBAL_LANGUAGE` | en | 设置导航页、qBittorrent和Filebrowser界面语言，chs为中文 |
| `GLOBAL_PORTAL_PATH` | /mypath | 导航页路径和所有Web服务的基础URL，务必设置为不常见路径。不能为“/"和空值，结尾不能加“/" |
| `TZ` | UTC | 时区，Asia/Shanghai为中国时区 |
| `NodeStatus_DSN` | | 可选，NodeStatus 探针服务端连接信息，保持默认空值为禁用。示例：wss://username:password@status.mydomain.com |

## 初次使用

1. 访问你的 "App URL" + ${GLOBAL_PORTAL_PATH} 即可到达导航页。
2. 点击AriaNg，这时会弹出认证失败警告，按下图把之前部署时设置的密码填入RPC密钥即可。
       <img src="https://user-images.githubusercontent.com/98247050/163184113-d0f09e78-01f9-4d4a-87b9-f4a9c1218253.png"  width="700"/>
3. 点击qBittorrent或者VueTorrent，输入默认用户名admin和默认密码adminadmin登陆。然后更改用户名和密码，务必设置为强密码。

   如果qBittorrent无法使用默认账户密码登陆，通过Filebrowser删除config/qBittorrent/config/qBittorrent.conf文件，然后通过ttyd执行下面命令：

```
      sv restart 1
```  
4. 通过Filebrowse将rclone.conf文件上传到config目录，可以通过编辑script.conf文件更改Rclone自动上传设置。
5. yt-dlp和gallery-dl下载工具可以通过ttyd在网页终端执行。   
    内置快捷指令：  
    dlpr：使用yt-dlp下载视频到videos文件夹下，下载完成后发送任务到rclone。 
    gdlr：使用gallery-dl下载文件到gallery_dl_downloads文件夹下，下载完成后发送任务到rclone。 
6. 如果升级版本后在script.conf文件中没有找到相关新增功能设置，参考最新版 [script.conf](https://github.com/wy580477/Leech-AIO-APP-EX/blob/main/content/script.conf) 文件，自行添加缺失的设置选项。

## 更多用法和注意事项

 1. Telegram通知功能，需要在Telegram内与@BotFather对话注册bot。然后获取自己账户的ChatID或者bot加入的频道ChatID。具体详细步骤请Google。
 
    然后编辑config/script.conf文件，将botid:token和ChatID填入对应选项，通知功能即生效。
 2. pyLoad已知Bug：
    - 解压后不能删除原文件，解决方法：Settings--Plugins--ExtractArchive，将"Move to trash instead delete"项设置为off。
 3. Doprax 部署后，将下列内容添加到 rclone.conf 文件，可以将容器本地存储作为 Rclone 的远程存储，便于在Rclone WebUI上手动上传。

       ```
       [local]
       type = alias
       remote = /mnt/data
       ```
       
 4. 对于不支持qBittorrent自定义路径的应用, 部署前在content目录下的Caddyfile文件中找到下列内容，去除每行开头的注释符号“#”:

       ```
       handle /api* {
              reverse_proxy * localhost:61804
       }
       ```

 5. Aria2 JSON-RPC 路径为： \$\{GLOBAL_PORTAL_PATH\}/jsonrpc   
    Aria2 XML-RPC 路径为： \$\{GLOBAL_PORTAL_PATH\}/rpc
