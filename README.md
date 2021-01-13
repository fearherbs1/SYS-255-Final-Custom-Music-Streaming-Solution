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

### Step 3 Configure Plex: 

1. Name your server then click next  

2. Now we will create a library. This is where your music files will be stored.  
Select the Music Type and Name it:  
![nameserver](https://i.imgur.com/UJb1wxf.png)  

3. Then we need to create a folder for our music to live in. I used this file path, but you can name it whatever you like:  

`sudo mkdir -p /plexmedia/music/sys255autodl`

4. Then we select that folder in the UI:  
![selectfolder](https://i.imgur.com/x9qf2Hu.png)  

5. Then we need to force plex to use the metadata we will be embedding in ourselves rather than searching the internet for it.  
Click advanced and check the “prefer local metadata” box   
![localmetadata](https://i.imgur.com/6YiItmE.png)  

6. Click “Add Library” and click through the rest of the setup guide.  

7. Once you are done you should be placed at the plex main screen

8. From here click “Sign in” at the top and sign in to your Plex Account to claim the server.  
![signup](https://i.imgur.com/aH8yFSm.png)

9. Once you sign in It will ask you to claim the server. Claim it.  
![claim](https://i.imgur.com/0AG81J1.png)  

10. Now navigate to the settings in the top right corner.   
**(NOTE!) It may ask you to allow insecure connections. Allow it so we can connect and change settings.**  
![settingspage](https://i.imgur.com/UDyeOPC.png)  


11. Now navigate to the Remote Access Section. Fill in the port you will be forwarding to enable the server to be accessed from the internet.  
The plex default is 32400, but I will be using 32402 due to me already having other plex servers. Also, include your internet upload speed   
in the box below the port selection.  
![networksettings](https://i.imgur.com/swJTCWd.png)  

12. NOTE:  Due to the nature of almost everyone having a different router, port forwarding is beyond the scope of this guide.  
I included what your rule should look like below. In my case I used a Ubiquiti USG. Google is your Friend here.   
Plex also has some help with this available [here](https://support.plex.tv/articles/200931138-troubleshooting-remote-access/).    

![portforward](https://i.imgur.com/J4UKt5Q.png)  

13. After that is complete your remote access should be working! 
![workingnetworksetting](https://i.imgur.com/lT8ak9s.png)  

14. One last setting in Plex, Navigate to Library settings and click ‘show advanced settings’. Check these three boxes:  
![3settings](https://i.imgur.com/X7lGOGq.png)  


### Step 4 Set Up Auto Music Download: 

1. First we need a source. Using the google account you created create a UNLISTED playlist on YouTube.   
And add your music to it like so:  
![playlist](https://i.imgur.com/OnLZQwF.png)

2. Now it's back to linux. Navigate to the folder you chose to store your music and create a file named autodl.sh:  
`sudo nano autodl.sh`

3. Then copy the code from [HERE](https://github.com/fearherbs1/SYS-255-Final-Custom-Music-Streaming-Solution/blob/main/AutoDLYoutube.sh) and paste it inside that file.   
This is the script that will grab our music.

4. Before you save and close the file, be sure to change These fields in the script to match your liking. Be sure to remove the parentheses and escape spaces with a \  
(Your album name here)                  ex: Auto\ Download\ Music  
(Your genre here)                             ex. Dance  
(Your Youtube Playlist link here)      ex. ([click me](https://www.youtube.com/playlist?list=PL_LZ3m675wGwLxZNgiwX_0vExUlqDelJn))    


5. Save and close with `Ctrl + o`  

6. Make the file Executable by doing:  
 `sudo chmod +x autodl.sh`
 
 
 7. Now we need to install Python, FFmpeg, and Youtube-DL for this script to work. This is done with these commands:
1.) `sudo apt-get update`  
2.) `sudo apt-get install python3 python3-pip -y`  
3.) `sudo pip3 install --upgrade youtube_dl`  
4.) `sudo apt-get install ffmpeg -y`  
 
 
 8. Now before having the script run every 10 minutes, we will test the script by running it manually.  
 If your script does not run make sure everything is on the same line as it is on github.  
 **NOTE:** The script does not output anything so it may seem like it's frozen. Let it run until you get  
 back to a command prompt. This can especially take a while if you have a large music playlist.  
   
  `sudo ./autodl.sh`  
 
 
 9. Once it's done you should be able to see your downloaded music in the folder   
`ls -l`  

![dldmusic](https://i.imgur.com/7joaYQT.png)  

 10. And If we go to plex and Scan our library: We should now see our music!    
 ![scan](https://i.imgur.com/uSbL7Vi.png)  
 
 ![musicinplex](https://i.imgur.com/1IZyS1u.png)  
  
 11. If you like, you can upload your own album art by clicking the little pencil edit button on the “Various Artists” album.   
 ![editalbum](https://i.imgur.com/YVOioBS.png)  
 
 
 12. Now we need to automate the running of our script. To do this, we need to make another script that changes to our folder and runs our autodl script. We can do this by:  
 
1.) Navigate to your home directory: `cd ~`  
2.) create our script: `sudo nano runautodl.sh`  
3.) Make it executable: `sudo chmod +x runautodl.sh\`  
4.) Open the file ( sudo nano runautodl.sh ) and add the following:  
```
cd "/plexmedia/music/sys255autodl"
./autodl.sh
```

5.) Save the file with `ctrl +o`  
6.) Open the root crontab with: `sudo crontab -e`   
7.) Add this line, changing the file path to where you saved your script:   
 `*/10 * * * * /home/sys255plex/sutodl/runautodl.sh`  
8.) Save and exit with: `Ctrl + o`   
 
![cron](https://i.imgur.com/uqdU7ec.png).  


13. This crontab sets the script to run once every 10 minutes. If you want to change it you can use this website to help you modify the entry.  


### Step 5 Creating our playlist: 

  Due to a bug in plex, we cannot just use album shuffle to listen to our music. This is because once a  
new song is auto downloaded and added to plex, plex puts it inside a different album even if the album  
name in the metadata is the same. We can get around this by creating a plex “smart playlist” instead.  
This will allow all of the songs to be in the same spot, as the smart playlists update when the library is updated.

1. Navigate to your library on plex and click “add to playlist” then “Create Smart Playlist”.   

![smartplaylist](https://i.imgur.com/w0aVhzX.png)   

2. Create the rule for the playlist just like the photo below, but replace “Certified Bumps” With your playlist name.

![args](https://i.imgur.com/rLD9Hta.png)  

3. Then click the save as dropdown and select, “Save as smart Playlist” and give it a name.    
![save](https://i.imgur.com/WICYLKv.png)  

4. Refresh your webpage, and then you will see a playlist section below your library with the playlist you created containing all of the songs!  
![musicv9](https://i.imgur.com/VljRqJV.png)  


### Step 6 Accessing Our Playlist:  
 
We can either access our playlist via the plex web app [like we have been doing so far](https://app.plex.tv/)  

Or we can access the playlist via Plexamp. Once the app is installed and you sign into your plex,     
the playlist will be shown. You can also download the playlist to your local device by holding the playlist and selecting “Download…”  

![plexamp](https://i.imgur.com/V7hxFIY.png)  


Here is an example of the player once a song is playing. We even get a cool visualizer based on the album art we uploaded earlier.    

![playing](https://i.imgur.com/F2fpD7p.png)


## Network Map: 
![netmap](https://i.imgur.com/w7MOaHP.png)  




