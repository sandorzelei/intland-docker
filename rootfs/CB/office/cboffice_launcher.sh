#!/bin/sh
# Copyright by Intland Software, http://www.intland.com
#
# All rights reserved.
#
# Last modification: 20 July 2014
#
# Do not modify this file!
#
# Firefox on Linux with Gnome:
#
# In Firefox handler should be configured under:
# about:config
# New -> Boolean
# network.protocol-handler.expose.cboffice boolean false
#
# Chrome on Linux with Gnome:
# For more information read cboffice.desktop
#

logfile=/tmp/cboffice.log

url=$1
if [ $# -eq 0 ]
then
    url=$URL
fi

#echo ARGS: $* > $logfile
#echo URL: $url >> $logfile

# Just remove cboffice: from the URL.
office_url=`echo $url | sed 's/cboffice:\/\///'`
exec soffice --nologo $office_url
