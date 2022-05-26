[点击前往中文说明](https://github.com/wy580477/Heroku-AIO-APP-EX/blob/main/README_chs.md)

## Acknowledgments

- [P3TERX/aria2.conf](https://github.com/P3TERX/aria2.conf)  Rely on the Aria2 script from P3TERX to automatically trigger the Rclone upload after the Aria2 downloads completed.
- [wahyd4/aria2-ariang-docker](https://github.com/wahyd4/aria2-ariang-docker)  Inspiration for this project.
- [bastienwirtz/homer](https://github.com/bastienwirtz/homer)  A very simple static homepage for your server.
- [mayswind/AriaNg](https://github.com/mayswind/AriaNg) | [filebrowser/filebrowser](https://github.com/filebrowser/filebrowser) | [aria2/aria2](https://github.com/aria2/aria2) | [rclone/rclone](https://github.com/rclone/rclone) | [yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp) | [userdocs/qbittorrent-nox-static](https://github.com/userdocs/qbittorrent-nox-static) | [WDaan/VueTorrent](https://github.com/WDaan/VueTorrent) | [OliveTin/OliveTin](https://github.com/OliveTin/OliveTin) | [pyload/pyload](https://github.com/pyload/pyload)

## Attention

 1. **Do not abuse Heroku's service or your account could get banned. Deploy at your own risk.**
 2. Aria2 & qBittorrent download speed is limited to 5MB/s on default.
 3. Anyone who can login into this app has full access to data in this app and Rclone remotes. Do not share with other ppl, and do not store sensitive information with this app.
 4. To prevent Heroku dyno from auto-sleeping, use website monitoring service such as uptimerobot to http ping your heroku domain every 10 mins.

[Overview](#Overview)

[Deployment](#Deployment)

[First run](#first)  

[More usages and precautions](#more)  

## <a id="Overview"></a>Overview

This project integrates yt-dlp, Aria2 + WebUI, qBittorrent + VueTorrent WebUI, pyLoad Download Manager, Rclone + WebUI with auto-upload function, Rclone Serve HTTP & Webdav, customizable portal page, OliveTin WebUI for shell commands, Filebrowser, ttyd web terminal, Xray Vmess proxy protocol.

[VPS version](https://github.com/wy580477/Aria2-AIO-Container)

![image](https://user-images.githubusercontent.com/98247050/170442242-9876b732-c3c0-4604-a820-f26545f1f620.png)

 1. Rclone auto-upload function only needs to prepare rclone.conf file, and all other configurations are set to go.
 2. Rclone runs on daemon mode, easy to manually transfer files and monitor transfers in real time on WebUI.
 3. You can connect Aria2, qBittorrent and Rclone from frontends running on other hosts.
 4. Auto-backup configuration files to Cloudflare Workers KV, and try to restore when dyno restarts.
 5. Execute predefined yt-dlp & Rclone commands from OliveTin WebUI.
 6. ttyd web terminal, which can execute yt-dlp and other commands on the command line.
 7. There are independent logs for each service in the log directory.

## <a id="Deployment"></a>Deployment

 **Do not deploy directly from this repository**  

 1. [Set up your Cloudflare workers KV service](https://github.com/wy580477/PaaS-Related/blob/main/SET_CLOUDFLARE_KV.md)
 2. Fork this this repository, then click Setting on fork repository page and check Template repository.
 3. Click new button: Use this template，create a new repository。
 4. For example, your Github username is bobby, and the new repository name is green. After logging in to heroku, visit <https://dashboard.heroku.com/new?template=https://github.com/bobby/green> to deploy.

## <a id="first"></a>First run

 1. After deployment, for example, your heroku domain name is bobby.herokuapp.com, the portal page path is /portal, then visit bobby.herokuapp.com/portal to reach the portal page.
 2. Click AriaNg, then authentication failure warning will pop up, fill in Aria2 secret RPC token with password set during deployment.  

![image](https://user-images.githubusercontent.com/98247050/165651080-b1b79ba6-7cc0-4c7c-b65b-fbc4256f59f9.png)  

 3. Click qBittorrent or VueTorrent, then login in with default user admin and default password adminadmin. Change default user/password to your own. Recommend strong password.
 4. Upload rclone.conf file to config folder via Filebrowser, you can edit script.conf file to change Rclone auto-upload settings.
 5. yt-dlp command can be executed through ttyd web terminal，for more information：<https://github.com/yt-dlp/yt-dlp#usage-and-options>  
    Built-in alias：  
    dlpr：Use yt-dlp to download videos to videos folder, then send task to Rclone after downloads completed.

## [Cloudflare Workers Reverse Proxy to bypass Heroku's 550-hour monthly limit](https://github.com/wy580477/PaaS-Related/blob/main/CF_Workers_Reverse_Proxy.md)

## <a id="more"></a>More usages and precautions

 1. Hit shift+F5 to force refresh if web services don't work properly. If app still doesn't work, clear cache and cookie of your heroku domain from browser.
 2. Known pyLoad bugs：
    - Redirect to http after login，solution: close the pyLoad page and reopen it.
    - Fail to delete archives after extraction, solution: Settings--Plugins--ExtractArchive, set "Move to trash instead delete" to off.
 3. After adding the following content to the end of Rclone config file, you can add local heroku storage in Rclone Web UI for manual upload.

```
[local]
type = alias
remote = /mnt/data
```

 4. It is not possible to configure a Rclone remote which requires web authentication through Rclone web UI in this app.
 5. Aria2 BT tracker list is auto-updated each time dyno restarted, rename or delete /content/aria2/tracker.sh file to disable this function.
 6. Portal page config file homer_en.yml and icon resources are under content/homer_conf directory in repository, use path as ./assets/tools/example.png to add the new icon to homer config file.
 7. Vmess proxy protocol: AlterID is 0, you can connect to either Vmess WS port 80 or Vmess WS tls port 443. Xray settings can be modified via content/xray.yaml file in repository. Heroku is difficult to connect in mainland China.   
   Example client setting:   
   ![image](https://user-images.githubusercontent.com/98247050/169536721-4b4fc824-454a-4bec-9342-40978b1d99a4.png)   
   With tls:   
   ![image](https://user-images.githubusercontent.com/98247050/169670311-1bf05652-8b5c-459a-9c24-41eef341006a.png)
