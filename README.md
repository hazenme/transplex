# transplex
Bash script for controlling Transmission's upstream limit based on outgoing Plex streams.

Originally produced by Reddit User KronK0321 https://www.reddit.com/user/KronK0321
I (Tim Clark) have modified it to poll a non-local Plex server, as well as look at the bandwidth used and not just the media bitrate (to account for transcoded streams)

They posted the links to pastebin on Reddit on 20160331

Here is a copy of their Reddit post to the Plex subreddit:

I built this script for my home server which runs the Transmission torrent client as well as Plex Media Server headless on Debian.

I wanted to make sure my torrent upstream bandwidth took a back seat to any Plex streams that are sent outside of the local network. I'm sure I could have implemented this via some QoS on my router or similar but this worked easily enough for me.

The script parses the XML Session Status returned by PMS, tallies the bitrate of all the "remote" streams and lowers Transmission's max upstream speed by the same amount. It's not a super elegant way to process the XML but it works pretty consistently. A friend suggested I submit it here for anyone interested.

Requires the transmission-cli and curl packages to be installed.

To control the service, use systemctl (ex. sudo systemctl stop transplex)

Source: http://pastebin.com/KUUjAGnE

SystemD service unit config: http://pastebin.com/Gq9C1329

PMS version 0.9.16.3

Transmission version 2.84
