## Attention

### Doprax has stopped offering free plan.

 1. **Do not abuse service from Doprax or your account could get banned. Deploy at your own risk.**
 2. **High disk usage will likely get your account banned.**
 3. Aria2 & qBittorrent download speed is limited to 5MB/s on default.
 4. Container filesystem is ephemeral - that means that any changes to the filesystem except volume mounted on /mnt/data/config whilst the dyno is running only last until that container is shut down or restarted.
 5. It is not possible to configure a Rclone remote which requires web authentication through Rclone Web UI in this app. You need to prepare rclone.conf file on other devices.
 6. No Rclone mount support.


[Overview](#Overview)

[Deployment](#Deployment)

[Envionment Variables](#Envionment_Variables)

[First run](#first)  

[More usages and precautions](#more)  

## <a id="Overview"></a>Overview

This project integrates yt-dlp, gallery-dl, Aria2 + WebUI, qBittorrent + VueTorrent WebUI, pyLoad Download Manager, Rclone + WebUI with auto-upload function, Rclone Serve HTTP & Webdav, customizable portal page, OliveTin WebUI for shell commands, Filebrowser, ttyd web terminal, Telegram notification.

 1. Rclone auto-upload function only needs to prepare rclone.conf file, and all other configurations are set to go.
 2. Rclone runs on daemon mode, easy to manually transfer files and monitor transfers in real time on WebUI.
 3. You can connect Aria2, qBittorrent and Rclone from frontends/services running on other hosts, including flexget/Radarr/Sonarr.
 4. Execute predefined yt-dlp, gallery-dl & Rclone commands from OliveTin WebUI.
 5. ttyd web terminal, which can execute yt-dlp and other commands on the command line.
 6. [runit](http://smarden.org/runit/index.html)-based process management, each service can be started and stopped independently.
 7. There are independent logs for each service in the log directory.
 8. [NodeStatus](https://github.com/cokemine/nodestatus) server monitor client.

## <a id="Deployment"></a>Deployment

 **Do not deploy directly from this repository** 

 1. Fork this this repository (uncheck "Copy the main branch only"), then click Setting on fork repository page and check Template repository.
 2. Go back to "Code" tab. Then Click new button: Use this template，create a new repository.
 3. Go to Setting tab on your new repo，Click "Branches"，set default branch to "doprax".
 
    <details>
    <summary>Screenshot</summary>

    ![avatar](/screenshots/branch.png)

    </details>

 3. Go to Doprax Dashboard page, click "Account",  then connect your github account.
 4. Click "Dashboard", creat a new app and click it.
 5. Click your newly created app, click "Import from my Github account" button, then import your new github repository.
 6. Click "Add environment variable", add environment variables according to the following table.
 7. Click "Volume", create a new volume and mount it to /mnt/data/config.
 
    <details>
    <summary>Screenshot</summary>

    ![avatar](/screenshots/volume.png)

    </details>

 7. Click "Deploy", then click "Resources". Set RAM to 512MB, click "Submit". Click the Start button and wait for the deployment to complete.

    <details>
    <summary>Screenshot</summary>

    ![avatar](/screenshots/deploy.png)

    </details>

## <a id="Envionment_Variables"></a>Envionment Variables

| Variable | Default | Description |
| :--- | :--- | :--- |
| `GLOBAL_USER` | admin | Username for all web services except qbit |
| `GLOBAL_PASSWORD` | password | Password for all web services except qbit, double as Aria2 RPC token. Recommend strong password. |
| `GLOBAL_LANGUAGE` | en | Set language of portal page, qbit & filebrowser.(en or chs) |
| `GLOBAL_PORTAL_PATH` | /mypath | Portal page & base URL for all web services. Set this to an uncommon path. Do not set to blank or '/' |
| `NodeStatus_DSN` | | Optional. NodeStatus server connection info, default blank value will disable NodeStatus. Example: wss://username:password@status.mydomain.com |


## <a id="first"></a>First run

   1. Visit your "App URL" + ${GLOBAL_PORTAL_PATH} to reach portal page.

      If your doprax domain gives you 503 or timeout error, here's a [workaround](https://github.com/wy580477/Leech-AIO-APP-EX/issues/67#issuecomment-1425437513) by using cloudflared tunnel.
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
   6. If you can't find function settings added in new version in script.conf after upgrading, refer to the latest [script.conf](https://github.com/wy580477/Leech-AIO-APP-EX/blob/doprax/content/script.conf) file，and add missing setting options by yourself.

## <a id="more"></a>More usages and precautions

 1. To enable Telegram notification function, you need to talk to @BotFather in Telegram to register a bot. Get ChatID of your Telegram account or ChatID of the channel which bot joined. Please Google for detailed steps.
 
    Edit the config/script.conf file. Fill in the corresponding options for botid:token and ChatID, then the notification function will take effect.
 2. Known pyLoad bugs：
    - Fail to delete archives after extraction, solution: Settings--Plugins--ExtractArchive, set "Move to trash instead delete" to off.
 3. After adding following content to rclone.conf file, you can use local container storage as a Rclone remote for manually uploading via Rclone Web UI.

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
