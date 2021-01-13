# Custom Music Downloading, Hosting, & Streaming Solution. (Google Music Replacement + more)
A guide to set up your own custom music solution with auto download from YouTube.  
by Thomas SYS-255 12-8-2020



## Description: 
  Due to the recent depreciation of google music, I was out of a music solution. Most of the music is not available on any streaming platforms, so I decided to make my own. This solution will automatically grab music I add to a youtube playlist and make it available to stream anywhere I have an internet connection. This project uses Ubuntu Server, PleX Media Server, Plexamp, Youtube, Youtube-DL, Bash, FFmpeg, and crontabs to make this possible.
  
 ## Overview:
 
 Basic Rundown of how this works.  

1. The user adds the song they want to an unlisted youtube playlist.
2. Every 10 minutes a script checks if there are any changes to the playlist.
3. If changes are detected the file is grabbed and logged.
4. The script then passes the file to FFmpeg to add metadata and convert it to MP3.
5. Plex Media Server detects the downloaded files and adds the music to its library using the metadata added from FFMpeg.
6. Plex’s Smart Playlists detect the song as a part of the auto downloaded music via metadata and adds it to the playlist.
7. Since Plex media server is available via WAN, The Plexamp App can now access the playlist.
8. The User can now stream the music to listen or download it to their local device to listen later on Plexamp.


## References:  
[FFmpeg Documentation](https://ffmpeg.org/documentation.html)  
[Plex Media Server Install Documentation](https://support.plex.tv/articles/200288586-installation/)  
[Youtube-DL Documentation](https://github.com/ytdl-org/youtube-dl/blob/master/README.md#readme)  
[Crontab Guru Scheduler](https://crontab.guru/)  


## Requirments:
1. [Ubuntu Server](https://ubuntu.com/download/server) Installation with internet access and enough storage for your music    
2. Router that allows port forwarding.  
3. [Google Account](https://accounts.google.com/signup?hl=en)    
4. [Plex Account](https://www.plex.tv/sign-up/)    
5. Mobile device with [Plexamp](https://plexamp.com/) Installed    
6. [Plex Pass](https://www.plex.tv/plex-pass/) ^     

^ Plexamp is currently only available with a Plex Pass. While you can still listen to your music anywhere with the standard plex client, it is not as full featured as Plexamp. It can be purchased as a subscription or a lifetime licence bound to your account.


## Build Documentation: 
(This guide assumes that Ubuntu Server 20.04 LTS is already installed and ready to go.)  


### Step 1 Static ip: 
Due to the fact that we will be creating a port forwarding rule in our router, we need to make sure that our ip does not change.   
This can be done via a DHCP reservation on your router, but to make things simple we will just set a static ip in ubuntu directly.  

1. Open the Network configuration file with admin privileges. This file is located in /etc/netplan

2. Yours may be named differently but mine is named: “00-installer-config.yaml”

3. Open the file and make the config look like the lines below, filling in your own network information (without quotes):
```
dhcp4: false
  addresses: [“Your ip”/”Subnet Mask in CIDR”]
  gateway4: “Default Gateway”
  nameservers:
    addresses: [“Nameserver 1”,”Nameserver 2”]
```
4. In my case the ip address 192.168.1.184 was used.

5. Apply the config with: sudo netplan apply

### Step 2 Install Plex Media Server:  

1.Add plex’s public repositories with these two commands:  

  1. `echo deb https://downloads.plex.tv/repo/deb public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list`
  2. `curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -`  

2. Update repos with:  `sudo apt-get update`

3. Install Plex Media server with: `sudo apt-get install plexmediaserver`

4. Enable plex to start on boot with: `sudo systemctl enable plexmediaserver.service`

5. Navigate to `http://”your ip address”:32400/web`

6. If you are successful, you should see the start page:
![startpage](https://i.imgur.com/bCxbwN9.png)

