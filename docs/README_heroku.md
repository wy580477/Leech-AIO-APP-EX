## Heroku stopped offering free product plans and shut down free dynos starting Nov. 28, 2022.

## Attention

 1. **Do not abuse service from Heroku or your account could get banned. Deploy at your own risk.**
 2. Aria2 & qBittorrent download speed is limited to 5MB/s on default.
 3. The Heroku filesystem is ephemeral - that means that any changes to the filesystem whilst the dyno is running only last until that dyno is shut down or restarted. In addition, dynos will restart every day.
 4. To prevent Heroku dyno from auto-sleeping, use website monitoring service such as uptimerobot to http ping your heroku domain every 10 mins.
 5. It is not possible to configure a Rclone remote which requires web authentication through Rclone web UI in this app. You need to prepare rclone.conf file on other devices.
 6. No Rclone mount support.


[Overview](#Overview)

[Deployment](#Deployment)

[First run](#first)  

[More usages and precautions](#more)  

## <a id="Overview"></a>Overview

This project integrates yt-dlp, gallery-dl, Aria2 + WebUI, qBittorrent + VueTorrent WebUI, pyLoad Download Manager, Rclone + WebUI with auto-upload function, Rclone Serve HTTP & Webdav, customizable portal page, OliveTin WebUI for shell commands, Filebrowser, ttyd web terminal, Telegram notification.

 1. Rclone auto-upload function only needs to prepare rclone.conf file, and all other configurations are set to go.
 2. Rclone runs on daemon mode, easy to manually transfer files and monitor transfers in real time on WebUI.
 3. You can connect Aria2, qBittorrent and Rclone from frontends/services running on other hosts, including flexget/Radarr/Sonarr.
 4. Auto-backup configuration files to Cloudflare Workers KV, and try to restore when dyno restarts.
 5. Execute predefined yt-dlp, gallery-dl & Rclone commands from OliveTin WebUI.
 6. ttyd web terminal, which can execute yt-dlp and other commands on the command line.
 7. [runit](http://smarden.org/runit/index.html)-based process management, each service can be started and stopped independently.
 8. There are independent logs for each service in the log directory.
 9. [NodeStatus](https://github.com/cokemine/nodestatus) server monitor client.

## <a id="Deployment"></a>Deployment

 **Do not deploy directly from this repository** 

 1. [Set up your Cloudflare workers KV service](https://github.com/wy580477/PaaS-Related/blob/main/SET_CLOUDFLARE_KV.md)

**KV is used as config files storage. Some updates needs to manully update config files.**  
**Alternatively you can delete KV data from Cloudflare dashboard to reset config files of your deployment. [IMAGE](https://user-images.githubusercontent.com/98247050/174501970-d22eac74-f2f1-496c-a100-8188832e4da7.png)**

 2. Fork this this repository, then click Setting on fork repository page and check Template repository.
 3. Go back to "Code" tab. Then Click new button: Use this template，create a new repository.
 4. For example, your Github username is bobby, and the new repository name is green. After logging in to heroku, visit <https://dashboard.heroku.com/new?template=https://github.com/bobby/green> to deploy.

## <a id="first"></a>First run

   1. Visit your_heroku_domain + ${GLOBAL_PORTAL_PATH} to reach portal page.
   2. Click AriaNg, then authentication failure warning will pop up, fill in Aria2 secret RPC token with password set during deployment.  

         <img src="https://user-images.githubusercontent.com/98247050/165651080-b1b79ba6-7cc0-4c7c-b65b-fbc4256f59f9.png"  width="700"/>

   3. Click qBittorrent or VueTorrent, then login in with default user admin and default password adminadmin. Change default user/password to your own. Recommend strong password.

      If you can't log in qBittorrent with the default account/password. Delete config/qBittorrent/config/qBittorrent.conf file via Filebrowser, then run the following command via ttyd:

```
      sv restart 1
```  
   4. Upload rclone.conf file to config folder via Filebrowser, you can edit script.conf file to change Rclone auto-upload settings.
   5. yt-dlp, gallery-dl & other commands can be executed through ttyd web terminal.   
      Built-in alias：  
      dlpr：Use yt-dlp to download videos to videos folder, then send task to Rclone after downloads completed.   
      gdlr: Use gallery-dl to download files to gallery_dl_downloads folder, then send task to Rclone after downloads completed.  
   6. If you can't find function settings added in new version in script.conf after upgrading, refer to the latest [script.conf](https://github.com/wy580477/Leech-AIO-APP-EX/blob/main/content/script.conf) file，and add missing setting options by yourself.

## <a id="more"></a>More usages and precautions

 1. To enable Telegram notification function, you need to talk to @BotFather in Telegram to register a bot. Get ChatID of your Telegram account or ChatID of the channel which bot joined. Please Google for detailed steps.
 
    Edit the config/script.conf file. Fill in the corresponding options for botid:token and ChatID, then the notification function will take effect.
 2. Known pyLoad bugs：
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
