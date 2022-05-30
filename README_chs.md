## 鸣谢

- [P3TERX/aria2.conf](https://github.com/P3TERX/aria2.conf)  依靠来自P3TERX的Aria2脚本，实现了Aria2下载完成自动触发Rclone上传。
- [wahyd4/aria2-ariang-docker](https://github.com/wahyd4/aria2-ariang-docker)  启发了本项目的总体思路。
- [bastienwirtz/homer](https://github.com/bastienwirtz/homer)  使用yaml配置文件的静态导航页，便于自定义。
- [mayswind/AriaNg](https://github.com/mayswind/AriaNg) | [filebrowser/filebrowser](https://github.com/filebrowser/filebrowser) | [aria2/aria2](https://github.com/aria2/aria2) | [rclone/rclone](https://github.com/rclone/rclone) | [yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp) | [userdocs/qbittorrent-nox-static](https://github.com/userdocs/qbittorrent-nox-static) | [WDaan/VueTorrent](https://github.com/WDaan/VueTorrent) | [OliveTin/OliveTin](https://github.com/OliveTin/OliveTin) | [pyload/pyload](https://github.com/pyload/pyload)

## 注意

 1. **请勿滥用，Colab/Heroku账号封禁风险自负。**
 2. Heroku的文件系统是临时性的，每24小时强制重启一次后会恢复到部署时状态。不适合长期下载和共享文件用途。
 3. Aria2和qBittorrent配置文件默认限速5MB/s。
 4. 所有可以登陆此APP的用户可以访问/修改此APP以及Rclone远程存储的所有数据，不要存放敏感数据，不要与他人共享使用。
 5. 免费Heroku dyno半小时无Web访问会休眠，可以使用uptimerobot、hetrixtools等免费VPS/网站监测服务定时http ping，保持持续运行。

[概述](#概述)

[部署方式](#部署方式)

[变量设置](#变量设置)  

[初次使用](#初次使用)  

[更多用法和注意事项](#更多用法和注意事项)  

## 概述

本项目集成了yt-dlp、Aria2+Rclone+qBittorrent+WebUI、pyLoad下载管理器、Rclone联动自动上传功能、、Rclone远程存储文件列表和Webdav服务、可自定义的导航页、Filebrowser轻量网盘、OliveTin网页执行shell命令、ttyd Web终端、Xray Vmess协议。(Colab 部署方式没有Rclone Webdav和Xray代理服务)

[VPS部署版本](https://github.com/wy580477/Aria2-AIO-Container)

![image](https://user-images.githubusercontent.com/98247050/170441806-1d6fd4f4-d1e3-479f-9893-13f1a3e03433.png)

 1. 联动上传功能只需要准备rclone.conf配置文件, 其他一切配置都预备齐全。
 2. Rclone以daemon方式运行，可在WebUI上手动传输文件和实时监测传输情况。
 3. Aria2、qBittorrent和Rclone可以接入其它host上运行的AriaNg/RcloneNg等前端面板。
 4. 自动备份相关配置文件，dyno重启时尝试恢复，实现了配置文件持久化。
 5. 可以从OliveTin网页端执行预定义yt-dlp和Rclone指令。
 6. ttyd网页终端，可命令行执行yt-dlp下载工具和其它命令。
 7. log目录下有每个服务独立日志。

## 部署方式

### Colab 部署步骤

 1. 在Google Drive根目录下建立一个名为 <code>AIO_FILES</code> 的文件夹.
 2. 将 [Colab.zip](https://github.com/wy580477/Colab-Heroku-AIO-APP-EX/archive/refs/heads/Colab.zip) 上传到 <code>AIO_FILES</code> 文件夹.
 3. 将 [AIO.ipynb](https://raw.githubusercontent.com/wy580477/Colab-Heroku-AIO-APP-EX/Colab/AIO.ipynb) 上传到Google Drive.
 4. 运行 AIO.ipynb.

### Heroku 部署步骤

  **请勿使用本仓库直接部署**  

  **Heroku修复安全漏洞中，目前无法通过网页从私有库部署**  

 1. [设置Cloudflare Workers KV服务](https://github.com/wy580477/PaaS-Related/blob/main/SET_CLOUDFLARE_KV_chs.md)
 2. 点击本仓库右上角Fork，再点击Create Fork。
 3. 在Fork出来的仓库页面上点击Setting，勾选Template repository。
 4. 然后点击Code返回之前的页面，点Setting下面新出现的按钮Use this template，起个随机名字创建新库。
 5. 比如你的Github用户名是bobby，新库名称是green。浏览器登陆heroku后，访问<https://dashboard.heroku.com/new?template=https://github.com/bobby/green> 即可部署。

 **Heroku部署变量设置**

对部署时可设定的变量做如下说明。
| 变量| 说明 |
| :--- | :--- |
| `GLOBAL_USER` | 用户名，适用于除qBittorrent外所有需要输入用户名的Web服务 |
| `GLOBAL_PASSWORD` | 务必修改为强密码，同样适用于除qBittorrent外所有需要输入密码的Web服务，同时也是Aria2 RPC密钥。 |
| `GLOBAL_LANGUAGE` | 设置导航页、qBittorrent和Filebrowser界面语言，chs为中文 |
| `GLOBAL_PORTAL_PATH` | 导航页路径和所有Web服务的基础URL，务必设置为不常见路径。不能为“/"和空值，结尾不能加“/" |
| `TZ` | 时区，Asia/Shanghai为中国时区 |
| `CLOUDFLARE_WORKERS_HOST` | Cloudflare Workers 服务域名 |
| `CLOUDFLARE_WORKERS_KEY` | Cloudflare Workers 服务密钥 |
| `VMESS_UUID` | Vmess协议UUID，务必修改，建议使用UUID工具生成 |

### 初次使用

- Heroku部署后:
    1. 比如你的heroku域名是bobby.herokuapp.com，导航页路径是/portal，访问bobby.herokuapp.com/portal 即可到达导航页。
    2. 点击AriaNg，这时会弹出认证失败警告，按下图把之前部署时设置的密码填入RPC密钥即可。
          <img src="https://user-images.githubusercontent.com/98247050/163184113-d0f09e78-01f9-4d4a-87b9-f4a9c1218253.png"  width="700"/>
    3. 点击qBittorrent或者VueTorrent，输入默认用户名admin和默认密码adminadmin登陆。然后更改用户名和密码，务必设置为强密码。
- 通过Filebrowse将rclone.conf文件上传到config目录，可以通过编辑script.conf文件更改Rclone自动上传设置。
- Colab部署后，可以将下列内容添加到rclone.conf文件，以便将Colab中挂载的Google Drive作为Rclone的远程存储。

      
      [local]
      type = alias
      remote = /content/drive/MyDrive
      

- yt-dlp下载工具可以通过ttyd在网页终端执行，使用方法详细见：<https://github.com/yt-dlp/yt-dlp#usage-and-options>  
    内置快捷指令：  
    dlpr：使用yt-dlp下载视频到videos文件夹下，下载完成后发送任务到rclone。  

## [Cloudflare Workers反代绕过Heroku非信用卡认证账号每月550小时限制](https://github.com/wy580477/PaaS-Related/blob/main/CF_Workers_Reverse_Proxy_chs.md)

### 更多用法和注意事项

 1. 如果网页访问APP出现故障，按下shift+F5强制刷新，如果还不行，从浏览器中清除app对应的heroku域名缓存和cookie。
 2. Rclone配置文件末尾加上如下内容，可以在Rclone Web前端中挂载Heroku本地存储，方便手动上传。
 3. pyLoad已知Bug：
    - 登陆后重定向到http，解决方法：关闭当前pyLoad页面，重新打开。
    - 解压后不能删除原文件，解决方法：Settings--Plugins--ExtractArchive，将"Move to trash instead delete"项设置为off。
 4. Heroku部署后，可以将下列内容添加到rclone.conf文件，可以将Heroku本地存储作为Rclone的远程存储，便于在Rclone WebUI上手动上传。

    ```
    [local]
    type = alias
    remote = /mnt/data
    ```

 4. 无法通过Rclone Web前端建立需要网页认证的存储配置。
 5. 每次dyno启动自动更新Aria2 BT tracker list，如果需要禁用，重命名或删除/content/aria2/tracker.sh文件。
 6. content/homer_conf目录下是导航页设置文件homer_chs(en).yml和图标资源，新加入的图标，在设置文件中要以./assets/tools/example.png这样的路径调用。
 7. Vmess协议AlterID为0，可用Vmess WS 80端口或者Vmess WS tls 443端口连接。Xray设置可以通过content/xray.yaml文件修改。Heroku国内直连可能需要使用Cloudflare或其它方式中转。
