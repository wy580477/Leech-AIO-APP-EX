[点击前往中文说明](https://github.com/wy580477/Heroku-AIO-APP-EX/blob/main/README_chs.md)

## Acknowledgments

- [P3TERX/aria2.conf](https://github.com/P3TERX/aria2.conf)  Rely on the Aria2 script from P3TERX to automatically trigger the Rclone upload after the Aria2 downloads completed.
- [wahyd4/aria2-ariang-docker](https://github.com/wahyd4/aria2-ariang-docker)  Inspiration for this project.
- [bastienwirtz/homer](https://github.com/bastienwirtz/homer)  A very simple static homepage for your server.
- [mayswind/AriaNg](https://github.com/mayswind/AriaNg) | [filebrowser/filebrowser](https://github.com/filebrowser/filebrowser) | [aria2/aria2](https://github.com/aria2/aria2) | [rclone/rclone](https://github.com/rclone/rclone) | [yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp) | [userdocs/qbittorrent-nox-static](https://github.com/userdocs/qbittorrent-nox-static) | [WDaan/VueTorrent](https://github.com/WDaan/VueTorrent) | [alexta69/metube](https://github.com/alexta69/metube) | [pyload/pyload](https://github.com/pyload/pyload)

## Attention

- Anyone who can login into this app has full access to data in this app and Rclone remotes. Do not share with other ppl, and do not store sensitive information with this app.

[Overview](#Overview)

[Deployment](#Deployment)

[First run](#first)  

[More usages and precautions](#more)  

## <a id="Overview"></a>Overview

This project integrates yt-dlp & its Web frontend metube, Aria2 + WebUI, qBittorrent + VueTorrent WebUI, pyLoad Download Manager, Rclone + WebUI with auto-upload function, Rclone Serve HTTP & Webdav, Filebrowser.

![image](https://user-images.githubusercontent.com/98247050/170442242-9876b732-c3c0-4604-a820-f26545f1f620.png)

 1. Rclone auto-upload function only needs to prepare rclone.conf file, and all other configurations are set to go.
 2. AMD64/Arm64/Armv7 multi-architecture support.
 3. Rclone runs on daemon mode, easy to manually transfer files and monitor transfers in real time on WebUI.
 4. You can connect Aria2, qBittorrent and Rclone from frontends running on other hosts.
 5. There are independent logs for each service in the log directory.

## <a id="Deployment"></a>Deployment

 1. Download [docker-compose file](https://raw.githubusercontent.com/wy580477/Aria2-AIO-Container/master/docker-compose_en.yml)
 2. Set envs and run container with following command:

            ```
            docker-compose -f docker-compose_en.yml up -d
            ```

## <a id="first"></a>First run

   1. visit your_domain/ip_address + \${GLOBAL_PORTAL_PATH} to reach portal page.
   2. Click AriaNg, then authentication failure warning will pop up, fill in Aria2 secret RPC token with password set during deployment.  

         <img src="https://user-images.githubusercontent.com/98247050/165651080-b1b79ba6-7cc0-4c7c-b65b-fbc4256f59f9.png"  width="700"/>

   3. Click qBittorrent or VueTorrent, then login in with default user admin and default password adminadmin. Change default user/password to your own. Recommend strong password.
   4. Upload rclone.conf file to config folder via Filebrowser, you can edit script.conf file to change Rclone auto-upload settings.

## <a id="more"></a>More usages and precautions

 1. Hit shift+F5 to force refresh if web services don't work properly. If app still doesn't work, clear cache and cookie of your domain/ip_address from browser.
 2. How to use yt-dlp via command line：  

            ```
            docker exec allinone yt-dlp
            # Built-in script：ytdlpup.sh
            # Download videos to /mnt/data/videos folder, then send job to Rclone.
            docker exec allinone ytdlpup.sh https://www.youtube.com/watch?v=rbDzVzBsbGM
            ```

 3. Considering security reasons, the initial user of Filebrowser doesn't have administrator privileges. If administrator privileges are wanted, run following commands:  

            ```
            docker exec -it allinone sh
            # enter container shell
            sv stop filebrowser
            # stop filebrowser service
            filebrowser -d /mnt/config/filebrowser.db users add username password --perm.admin
            # add new account with admin privileges
            sv start filebrowser
            # start filebrowser service
            ```
 4. Known pyLoad bugs：
    - Redirect to http after login，solution: close the pyLoad page and reopen it.
    - Fail to delete archives after extraction, solution: Settings--Plugins--ExtractArchive, set "Move to trash instead delete" to off.
 5. After adding following content to rclone.conf file, you can use local storage as a Rclone remote for manually uploading via Rclone Web UI.

            ```
            [local]
            type = alias
            remote = /mnt/data
            ```

 6. It is not possible to configure a Rclone remote which requires web authentication through Rclone web UI in this app.
