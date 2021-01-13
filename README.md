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

