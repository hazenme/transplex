#!/bin/bash

  ########################################################
  #                                                      #
  # transplex.sh                                         #
  # Created by KronK0321                                 #
  # Used for controlling Transmission's upstream limit   #
  #  based on outgoing Plex streams.                     #
  #                                                      #
  ########################################################

# Desired Transmission upload speeds in KB/s
maxupspeed=1850
minupspeed=350

# Transmission info
tr_hostname=localhost
tr_port=9091
tr_username=USERNAME
tr_password=PASSWORD

# Plex account token
token=REDACTED

# Local network
local_ip=192.168.1

# How long, in seconds, between checking for outgoing plex streams
delay=10

while true; do

        totalbitrate=0

        while read LINE; do

                if [[ $LINE == \<Video* ]]; then
                        # start of a video section
                        bitrate=0
                        isremote=0

                elif [[ $LINE == \<Stream* ]]; then
                        # each stream entry is read and parsed to extract the bitrate
                        streambitrate=$(echo $LINE | grep -o bitrate=\"[0-9]* | sed 's/bitrate=\"//g')
                        if [[ $streambitrate =~ [0-9]+$ ]]; then
                                let bitrate+=$streambitrate
                        fi

                elif [[ $LINE == \<Player* ]]; then
                        # determine if is a remote stream
                        ip=$(echo $LINE | grep -o address=\"[0-9]*\.[0-9]*\.[0-9]*\.[0-9]* | sed 's/address=\"//g')
                        if [[ ! $ip =~ $local_ip ]]; then
                                isremote=1
                        fi

                elif [[ $LINE == *\<\/Video\>* ]]; then
                        # end of a video section, count this if its remote
                        if [[ $isremote = 1 ]]; then
                                let totalbitrate+=$bitrate
                        fi
                fi

        # pull the information from plex web app
        done < <(curl --silent localhost:32400/status/sessions?X-Plex-Token=$token)

        # need to work in Kb/s
        upspeed=$(( $maxupspeed - ( $totalbitrate / 8 ) ))

        # never set the upload speed below specified value
        if [[ $upspeed -lt $minupspeed ]]; then
                upspeed=$minupspeed
        fi

        /usr/bin/transmission-remote $tr_hostname:$tr_port -n "$tr_username":"$tr_password" -u $upspeed

        sleep $delay
done;
