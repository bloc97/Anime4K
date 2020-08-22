@echo off

setlocal EnableDelayedExpansion

set "confMPV=%~dp0"
set "confDIR=Anime4K"
git clone https://github.com/bloc97/Anime4K.git %confDIR%

cd /d "%AppData%"

if not exist "mpv" mkdir mpv"
if not exist "mpv\shaders" (
  mkdir "mpv\shaders"
) else (
  del "mpv\shaders\%confDIR%*.glsl"
)

cd /d "%confMPV%\%confDIR%\glsl"

for /R "%confMPV%\%confDIR%\glsl" %%f in (*.glsl) do (
  echo %%f
  echo %AppData%\mpv\shaders
  copy "%%f" "%AppData%\mpv\shaders"
)

cd /d "%AppData%\mpv"

echo CTRL+1 change-list glsl-shaders set "~~/shaders/Anime4K_Upscale_CNN_L_x2_Denoise.glsl;~~/shaders/Anime4K_Auto_Downscale_Pre_x4.glsl;~~/shaders/Anime4K_Upscale_CNN_M_x2_Deblur.glsl"                                                                                                              >  input.conf
echo CTRL+2 change-list glsl-shaders set "~~/shaders/Anime4K_Upscale_CNN_L_x2_Denoise.glsl;~~/shaders/Anime4K_Auto_Downscale_Pre_x4.glsl;~~/shaders/Anime4K_DarkLines_HQ.glsl;~~/shaders/Anime4K_ThinLines_HQ.glsl;~~/shaders/Anime4K_Upscale_CNN_M_x2_Deblur.glsl"                                    >> input.conf
echo CTRL+3 change-list glsl-shaders set "~~/shaders/Anime4K_Upscale_CNN_L_x2_Denoise.glsl;~~/shaders/Anime4K_Auto_Downscale_Pre_x4.glsl;~~/shaders/Anime4K_Deblur_DoG.glsl;~~/shaders/Anime4K_DarkLines_HQ.glsl;~~/shaders/Anime4K_ThinLines_HQ.glsl;~~/shaders/Anime4K_Upscale_CNN_M_x2_Deblur.glsl" >> input.conf
echo CTRL+4 change-list glsl-shaders set "~~/shaders/Anime4K_Denoise_Bilateral_Mode.glsl;~~/shaders/Anime4K_Upscale_CNN_M_x2_Deblur.glsl"                                                                                                                                                              >> input.conf
echo CTRL+5 change-list glsl-shaders set "~~/shaders/Anime4K_Denoise_Bilateral_Mode.glsl;~~/shaders/Anime4K_DarkLines_HQ.glsl;~~/shaders/Anime4K_ThinLines_HQ.glsl;~~/shaders/Anime4K_Upscale_CNN_M_x2_Deblur.glsl"                                                                                    >> input.conf
echo CTRL+6 change-list glsl-shaders set "~~/shaders/Anime4K_Denoise_Bilateral_Mode.glsl;~~/shaders/Anime4K_Deblur_DoG.glsl;~~/shaders/Anime4K_DarkLines_HQ.glsl;~~/shaders/Anime4K_ThinLines_HQ.glsl;~~/shaders/Anime4K_Upscale_CNN_M_x2_Deblur.glsl"                                                 >> input.conf
echo CTRL+0 change-list glsl-shaders clr ""                                                                                                                                                                                                                                                            >> input.conf

echo profile=gpu-hq              >  mpv.conf
echo scale=ewa_lanczossharp      >> mpv.conf
echo cscale=ewa_lanczossharp     >> mpv.conf
echo video-sync=display-resample >> mpv.conf
echo interpolation               >> mpv.conf
echo tscale=oversample           >> mpv.conf

echo.
echo Please delete the "%confDIR%" folder manually if you dont need it anymore.

pause
