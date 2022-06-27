## Attention

 1. **Do not abuse service from Heroku or your account could get banned. Deploy at your own risk.**
 2. Aria2 & qBittorrent download speed is limited to 5MB/s on default.
 3. The Heroku filesystem is ephemeral - that means that any changes to the filesystem whilst the dyno is running only last until that dyno is shut down or restarted. In addition, dynos will restart every day.
 4. To prevent Heroku dyno from auto-sleeping, use website monitoring service such as uptimerobot to http ping your heroku domain every 10 mins.

[Overview](#Overview)

[Deployment](#Deployment)

[First run](#first)  

[More usages and precautions](#more)  

## <a id="Overview"></a>Overview

This project integrates yt-dlp, gallery-dl, Aria2 + WebUI, qBittorrent + VueTorrent WebUI, pyLoad Download Manager, Rclone + WebUI with auto-upload function, Rclone Serve HTTP & Webdav, customizable portal page, OliveTin WebUI for shell commands, Filebrowser, ttyd web terminal, Xray Vmess proxy protocol.

 1. Rclone auto-upload function only needs to prepare rclone.conf file, and all other configurations are set to go.
 2. Rclone runs on daemon mode, easy to manually transfer files and monitor transfers in real time on WebUI.
 3. You can connect Aria2, qBittorrent and Rclone from frontends/services running on other hosts, including flexget/Radarr/Sonarr.
 4. Auto-backup configuration files to Cloudflare Workers KV, and try to restore when dyno restarts.
 5. Execute predefined yt-dlp, gallery-dl & Rclone commands from OliveTin WebUI.
 6. ttyd web terminal, which can execute yt-dlp and other commands on the command line.
 7. There are independent logs for each service in the log directory.

## <a id="Deployment"></a>Deployment

 **Do not deploy directly from this repository** 

 1. [Set up your Cloudflare workers KV service](https://github.com/wy580477/PaaS-Related/blob/main/SET_CLOUDFLARE_KV.md)

**KV is used as config files storage. Some updates needs to manully update config files.**  
**Alternatively you can delete KV data from Cloudflare dashboard to reset config files of your deployment. [IMAGE](https://user-images.githubusercontent.com/98247050/174501970-d22eac74-f2f1-496c-a100-8188832e4da7.png)**

 2. Fork this this repository, then click Setting on fork repository page and check Template repository.
 3. Click new button: Use this template，create a new repository。
 4. For example, your Github username is bobby, and the new repository name is green. After logging in to heroku, visit <https://dashboard.heroku.com/new?template=https://github.com/bobby/green> to deploy.

## <a id="first"></a>First run

   1. Visit your_heroku_domain + \${GLOBAL_PORTAL_PATH} to reach portal page.
   2. Click AriaNg, then authentication failure warning will pop up, fill in Aria2 secret RPC token with password set during deployment.  

         <img src="https://user-images.githubusercontent.com/98247050/165651080-b1b79ba6-7cc0-4c7c-b65b-fbc4256f59f9.png"  width="700"/>

   3. Click qBittorrent or VueTorrent, then login in with default user admin and default password adminadmin. Change default user/password to your own. Recommend strong password.
   4. Upload rclone.conf file to config folder via Filebrowser, you can edit script.conf file to change Rclone auto-upload settings.
   5. yt-dlp, gallery-dl & other commands can be executed through ttyd web terminal.   
      Built-in alias：  
      dlpr：Use yt-dlp to download videos to videos folder, then send task to Rclone after downloads completed.   
      gdlr: Use gallery-dl to download files to gallery_dl_downloads folder, then send task to Rclone after downloads completed.  

## [Cloudflare Workers Reverse Proxy to bypass Heroku's 550-hour monthly limit](https://github.com/wy580477/PaaS-Related/blob/main/CF_Workers_Reverse_Proxy.md)

## <a id="more"></a>More usages and precautions

 1. Hit shift+F5 to force refresh if web services don't work properly. If app still doesn't work, clear cache and cookie of your heroku domain from browser.
 2. Known pyLoad bugs：
    - Redirect to http after login，solution: close the pyLoad page and reopen it.
    - Fail to delete archives after extraction, solution: Settings--Plugins--ExtractArchive, set "Move to trash instead delete" to off.
 3. After adding following content to rclone.conf file, you can use local heroku storage as a Rclone remote for manually uploading via Rclone Web UI.

      ```
      [local]
      type = alias
      remote = /mnt/data
      ```

 4. For apps which don't support custom path for qBittorrent, uncomment followings line in Caddyfile under config/caddy folder before deployment:

            handle /api* {       
                    reverse_proxy * localhost:61804
            }

 5. Aria2 JSON-RPC path： \${GLOBAL_PORTAL_PATH}/jsonrpc   
    Aria2 XML-RPC path： \${GLOBAL_PORTAL_PATH}/rpc
 6. It is not possible to configure a Rclone remote which requires web authentication through Rclone web UI in this app.
 7. Vmess proxy protocol: AlterID is 0, you can connect to either Vmess WS port 80 or Vmess WS tls port 443. Xray settings can be modified via content/xray.yaml file in repository. Heroku is difficult to connect in mainland China.

      <details>
      <summary>Example client setting</summary>
      <img src="https://user-images.githubusercontent.com/98247050/169536721-4b4fc824-454a-4bec-9342-40978b1d99a4.png"/>
      </details>
      <details>
      <summary>Example client setting with tls</summary>
      <img src="https://user-images.githubusercontent.com/98247050/169670311-1bf05652-8b5c-459a-9c24-41eef341006a.png"/>
      </details>
