/usr/local/bin/youtube-dl --download-archive downloaded.txt --yes-playlist --no-post-overwrites -ciwx --audio-format mp3 --add-metadata --postprocessor-args "-metadata album=(Your album name here) -metadata album_artist=Various\ Artists -metadata genre=(your genere here)" -o "%(title)s.%(ext)s" "(Your Youtube Playlist link here)" > log.txt 2>&1;
printf "\n Finished at: " >> log.txt;
date +%m-%d-%Y_%I:%M:%S >> log.txt;

