#!/usr/bin/env zsh

# Connect headphones
rfkill unblock bluetooth          # allows you to power on the bluetooth radio
sleep 2                           # wait for the
coproc bluetoothctl               # start non interactive use with blootoothctl
echo 'power on\n' >&p             # turn on bluetooth radio
exec 4<&p
echo  'connect E9:08:EF:56:12:64\n' >&p # connect mac address of my headphone
exec 5<&p
echo  'exit\n' >&p
exec 6<&p
coproc :
cat <&4
cat <&5
cat <&6


# use this to find the card.
pactl list cards short

# allow the card to be seen as a sink
pactl set-card-profile bluez_card.E9_08_EF_56_12_64 a2dp_sink

# set the default sink to the bluez sink
pacmd set-default-sink bluez_sink.E9_08_EF_56_12_64


# Move all currently playing audio streams to sink
pacmd list-sink-inputs | grep "index:"
pacmd move-sink-input [integer] bluez_sink.E9_08_EF_56_12_64
