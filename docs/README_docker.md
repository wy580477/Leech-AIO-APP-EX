[Overview](#Overview)

[Deployment](#Deployment)

[First run](#first)

[More usages and precautions](#more)  

## <a id="Overview"></a>Overview

This project integrates yt-dlp & its Web frontend metube, gallery-dl, Aria2 + WebUI, qBittorrent + VueTorrent WebUI, pyLoad Download Manager, Rclone + WebUI with auto-upload function, Rclone Serve HTTP & Webdav, Filebrowser, Telegram notification.

 1. Rclone auto-upload function only needs to prepare rclone.conf file, and all other configurations are set to go.
 2. AMD64/Arm64 multi-architecture support, Lite version has additional Armv7 support.
 3. Execute predefined yt-dlp, gallery-dl & Rclone commands from OliveTin WebUI.
 4. Rclone runs on daemon mode, easy to manually transfer files and monitor transfers in real time on WebUI.
 5. You can connect to Aria2, qBittorrent from other frontends/services，including Telegram bot/flexget/Radarr/Sonarr.
 6. [runit](http://smarden.org/runit/index.html)-based process management, each service can be started and stopped independently.
 7. There are independent logs for each service in the log directory.

## <a id="Deployment"></a>Deployment

 1. Download [docker-compose file](https://github.com/wy580477/Leech-AIO-APP-EX/blob/docker/docker-compose_en.yml). Lite version without pyLoad has smaller image size.
 2. Set envs and run container with following command:

            docker-compose -f docker-compose_en.yml up -d

## <a id="first"></a>First run

   1. visit your_domain/ip_address + ${GLOBAL_PORTAL_PATH} to reach portal page.
   2. Click AriaNg, then authentication failure warning will pop up, fill in Aria2 secret RPC token with password set during deployment and check whether protocol and port settings match what is displayed in the browser address bar.  

         <img src="https://user-images.githubusercontent.com/98247050/165651080-b1b79ba6-7cc0-4c7c-b65b-fbc4256f59f9.png"  width="700"/>

   3. Click qBittorrent or VueTorrent, then login in with default user admin and default password adminadmin. Change default user/password to your own. Recommend strong password.

      If you can't log in qBittorrent with the default account/password. Delete config/qBittorrent/config/qBittorrent.conf file via Filebrowser, then run the following command in host terminal:
```
       docker exec allinone sv restart qBittorrent
```  
   4. It's not possible to configure a Rclone remote which requires web authentication through Rclone web UI in this app. You need to upload rclone.conf file to config folder via Filebrowser, you can edit script.conf file to change Rclone auto-upload settings.
   5. If you can't find function settings added in new version in script.conf after upgrading, refer to the latest [script.conf](https://github.com/wy580477/Leech-AIO-APP-EX/blob/docker/content/script.conf) file，and add missing setting options by yourself.

## <a id="more"></a>More usages and precautions
 
 1. To enable Telegram notification function, you need to talk to @BotFather in Telegram to register a bot. Get ChatID of your Telegram account or ChatID of the channel which bot joined. Please Google for detailed steps.
 
    Edit the config/script.conf file. Fill in the corresponding options for botid:token and ChatID, then the notification function will take effect.
 2. You can set up proxy for metube in config/metube.conf:
```
       YTDL_OPTIONS="{\"postprocessors\":[{\"key\":\"Exec\",\"exec_cmd\":\"ytdlptorclone.sh\"}],\"proxy\":\"socks5://127.0.0.1:10808\",\"noprogress\":true}"
```
 3. How to use yt-dlp & gallery-dl via command line：  


            docker exec allinone yt-dlp
            # Built-in script：dlpr
            # Download videos to videos folder, then send job to Rclone.
            docker exec allinone dlpr https://www.youtube.com/watch?v=rbDzVzBsbGM

            docker exec allinone gallery-dl
            # Built-in script：gdlr
            # Download files to gallery_dl_downloads folder, then send job to Rclone.
            docker exec allinone gdlr https://www.reddit.com/r/aww/comments/vb14vy/urgent_baby_flamingo_doing_flamingo_leg/

 4. For apps which don't support custom path for qBittorrent, uncomment followings line in Caddyfile under config/caddy folder:


            handle /api* {       
                    reverse_proxy * localhost:61804
            }

    Then run following command for change to take effect:


            docker exec allinone sv restart caddy

 5. Aria2 JSON-RPC path： \${GLOBAL_PORTAL_PATH}/jsonrpc      
    Aria2 XML-RPC path： \${GLOBAL_PORTAL_PATH}/rpc
 6. Considering security reasons, the initial user of Filebrowser doesn't have administrator privileges. If administrator privileges are wanted, run following commands:  


            docker exec -it allinone sh
            # enter container shell
            sv stop filebrowser
            # stop filebrowser service
            filebrowser -d /mnt/data/config/filebrowser.db users add username password --perm.admin
            # add new account with admin privileges
            sv start filebrowser
            # start filebrowser service

 7. Known pyLoad bugs：
    - Redirect to http after login，solution: close the pyLoad page and reopen it.
    - Fail to delete archives after extraction, solution: Settings--Plugins--ExtractArchive, set "Move to trash instead delete" to off.
 8. After adding following content to rclone.conf file, you can use local storage as a Rclone remote for manually uploading via Rclone Web UI.


            [local]
            type = alias
            remote = /mnt/data

