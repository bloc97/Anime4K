ffmpeg -i HR.png -vf scale=iw/2:ih/2 -sws_flags area LR-Area.png
ffmpeg -i HR.png -vf scale=iw/2:ih/2 -sws_flags bicubic LR-Bicubic.png
ffmpeg -i HR.png -vf scale=iw/2:ih/2 -sws_flags lanczos LR-Lanczos.png