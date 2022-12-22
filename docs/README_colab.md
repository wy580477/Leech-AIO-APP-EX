## Attention

 1. **Do not abuse service from Colab or your account could get banned. Deploy at your own risk.**
 2. Aria2 & qBittorrent download speed is limited to 5MB/s on default.
 3. It is not possible to configure a Rclone remote which requires web authentication through Rclone web UI in this app.

[Overview](#Overview)

[Deployment](#Deployment)

[First run](#first)  

[More usages and precautions](#more)  

## <a id="Overview"></a>Overview

This project integrates yt-dlp, gallery-dl, Aria2 + WebUI, qBittorrent + VueTorrent WebUI, pyLoad Download Manager, Rclone + WebUI with auto-upload function, Rclone Serve HTTP, OliveTin WebUI for shell commands, Filebrowser, ttyd web terminal.

 1. Rclone auto-upload function only needs to prepare rclone.conf file, and all other configurations are set to go.
 2. Rclone runs on daemon mode, easy to manually transfer files and monitor transfers in real time on WebUI.
 3. Auto-backup configuration files to Google Drive, and try to restore when dyno restarts.
 4. Execute predefined yt-dlp, gallery-dl & Rclone commands from OliveTin WebUI.
 5. ttyd web terminal, which can execute yt-dlp and other commands on the command line.
 6. There are independent logs for each service in the log directory.

## <a id="Deployment"></a>Deployment

 1. Make a folder named <code>AIO_FILES</code> in your Google Drive root folder.
 2. Upload [main.zip](https://github.com/wy580477/Leech-AIO-APP-EX/archive/refs/heads/Colab.zip) to <code>AIO_FILES</code> folder.
 3. Upload [AIO.ipynb](https://github.com/wy580477/Heroku-AIO-APP-EX/raw/Colab/AIO.ipynb) to Google Drive.
 4. Run AIO.ipynb.
 5. If you can't find function settings added in new version in script.conf after upgrading, refer to the latest [script.conf](https://github.com/wy580477/Leech-AIO-APP-EX/blob/Colab/content/script.conf) file，and add missing setting options by yourself.

## <a id="first"></a>First run

- Upload rclone.conf file to config folder via Filebrowser, you can edit script.conf file to change Rclone auto-upload settings.
- Add following content to rclone.conf file in order to use your mounted Google Drive as a Rclone remote.

      [local]
      type = alias
      remote = /content/drive/MyDrive

- yt-dlp, gallery-dl & other commands can be executed through ttyd web terminal.     
    Built-in alias：     
    dlpr: Use yt-dlp to download videos to videos folder, then send task to Rclone after downloads completed.    
    gdlr: Use gallery-dl to download files to gallery_dl_downloads folder, then send task to Rclone after downloads completed.

## <a id="more"></a>More usages and precautions

1. To enable Telegram notification function, you need to talk to @BotFather in Telegram to register a bot. Get ChatID of your Telegram account or ChatID of the channel which bot joined. Please Google for detailed steps.
 
    Edit the config/script.conf file. Fill in the corresponding options for botid:token and ChatID, then the notification function will take effect.

 2. Known pyLoad bugs：
    - Redirect to http after login，solution: close the pyLoad page and reopen it.
    - Fail to delete archives after extraction, solution: Settings--Plugins--ExtractArchive, set "Move to trash instead delete" to off.
