[点击前往中文说明](https://github.com/wy580477/Leech-AIO-APP-EX/blob/Colab/README_chs.md)

## Attention

 1. **Do not abuse service from Colabor your account could get banned. Deploy at your own risk.**
 2. Aria2 & qBittorrent download speed is limited to 5MB/s on default.
 3. Anyone who can login into this app has full access to data in this app and Rclone remotes. Do not share with other ppl, and do not store sensitive information with this app.

[Overview](#Overview)

[Deployment](#Deployment)

[First run](#first)  

[More usages and precautions](#more)  

## <a id="Overview"></a>Overview

This project integrates yt-dlp, Aria2 + WebUI, qBittorrent + VueTorrent WebUI, pyLoad Download Manager, Rclone + WebUI with auto-upload function, Rclone Serve HTTP, OliveTin WebUI for shell commands, Filebrowser, ttyd web terminal.

![image](https://user-images.githubusercontent.com/98247050/170442242-9876b732-c3c0-4604-a820-f26545f1f620.png)

 1. Rclone auto-upload function only needs to prepare rclone.conf file, and all other configurations are set to go.
 2. Rclone runs on daemon mode, easy to manually transfer files and monitor transfers in real time on WebUI.
 3. You can connect Aria2, qBittorrent and Rclone from frontends running on other hosts.
 4. Auto-backup configuration files to Google Drive, and try to restore when dyno restarts.
 5. Execute predefined yt-dlp & Rclone commands from OliveTin WebUI.
 6. ttyd web terminal, which can execute yt-dlp and other commands on the command line.
 7. There are independent logs for each service in the log directory.

## <a id="Deployment"></a>Deployment

 1. Make a folder named <code>AIO_FILES</code> in your Google Drive root folder.
 2. Upload [main.zip](https://github.com/wy580477/Leech-AIO-APP-EX/archive/refs/heads/Colab.zip) to <code>AIO_FILES</code> folder.
 3. Upload [AIO.ipynb](https://github.com/wy580477/Heroku-AIO-APP-EX/raw/Colab/AIO.ipynb) to Google Drive.
 4. Run AIO.ipynb.

## <a id="first"></a>First run

- Upload rclone.conf file to config folder via Filebrowser, you can edit script.conf file to change Rclone auto-upload settings.
- Add following content to rclone.conf file in order to use your mounted Google Drive as a Rclone remote.

      [local]
      type = alias
      remote = /content/drive/MyDrive

- yt-dlp command can be executed through ttyd web terminal，for more information：<https://github.com/yt-dlp/yt-dlp#usage-and-options>  
    Built-in alias：  
    dlpr：Use yt-dlp to download videos to videos folder, then send task to Rclone after downloads completed.

## <a id="more"></a>More usages and precautions

 1. Known pyLoad bugs：
    - Redirect to http after login，solution: close the pyLoad page and reopen it.
    - Fail to delete archives after extraction, solution: Settings--Plugins--ExtractArchive, set "Move to trash instead delete" to off.
 2. It is not possible to configure a Rclone remote which requires web authentication through Rclone web UI in this app.

## Acknowledgments

- [P3TERX/aria2.conf](https://github.com/P3TERX/aria2.conf)  Rely on the Aria2 script from P3TERX to automatically trigger the Rclone upload after the Aria2 downloads completed.
- [wahyd4/aria2-ariang-docker](https://github.com/wahyd4/aria2-ariang-docker)  Inspiration for this project.
- [bastienwirtz/homer](https://github.com/bastienwirtz/homer)  A very simple static homepage for your server.
- [mayswind/AriaNg](https://github.com/mayswind/AriaNg) | [filebrowser/filebrowser](https://github.com/filebrowser/filebrowser) | [aria2/aria2](https://github.com/aria2/aria2) | [rclone/rclone](https://github.com/rclone/rclone) | [yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp) | [userdocs/qbittorrent-nox-static](https://github.com/userdocs/qbittorrent-nox-static) | [WDaan/VueTorrent](https://github.com/WDaan/VueTorrent) | [OliveTin/OliveTin](https://github.com/OliveTin/OliveTin) | [pyload/pyload](https://github.com/pyload/pyload)
