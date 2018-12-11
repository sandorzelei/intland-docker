@ECHO OFF
REM DO NOT MODIFY THIS FILE UNLESS YOU KNOW WHAT YOU ARE DOING
REM This is the change-content trigger hook
"/your_install_dir/scmloop\scmloop.bat" -scmType perforce -mode post_receive %*

