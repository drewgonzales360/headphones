#!/usr/bin/env zsh
################################################################################
# I use this shell script to connect my headphones to my desktop.
################################################################################

################################################################################
# This function takes one parameter and connects as an a2dp sink
# @param $1 mac address seprated with colons E9:08:EF:56:12:64
function connect_bluetooth() {
	rfkill unblock bluetooth          # allows you to power on the bluetooth radio
	sleep 1                           # wait for the
	coproc bluetoothctl               # start non interactive use with blootoothctl
	echo 'power on\n' >&p             # turn on bluetooth radio
	exec 4<&p
	echo "connect $1\n" >&p           # connect mac address of my headphone
	exec 5<&p
	echo 'exit\n' >&p
	exec 6<&p
	coproc :
	cat <&4
	cat <&5
	cat <&6
	# allow the card to be seen as a sink
	pactl set-card-profile bluez_card.$(echo $1 | sed 's/:/_/g') a2dp_sink
}
################################################################################

################################################################################
# This function will take one parameter and set it as the default sink, then
# start streaming all audio to it.
# @param $1 bluez_sink.E9_08_EF_56_12_64
function set-sink() {
	# set the default sink to the bluez sink
	pacmd set-default-sink $1

	# Move all currently playing audio streams to sink
	# List all current streams
	SINKS=($(pacmd list-sink-inputs | grep "index:" | awk  -F" " '{print $2}'))

	# Move all current streams to my sink
	for i in ${SINKS[@]}; do
		pacmd move-sink-input ${i} $1
	done
}
################################################################################

################################################################################
# connect headphones and use it as default sound sink
# @param $1 mac address seprated with colons E9:08:EF:56:12:64
function use_mpow() {
	mpow_mac_address=E9:08:EF:56:12:64
	connect_bluetooth $mpow_mac_address
	set-sink bluez_sink.$(echo $mpow_mac_address | sed 's/:/_/g')
}

function use_speakers() {
	set-sink alsa_output.pci-0000_00_1b.0.analog-stereo
}
################################################################################

usage="$(basename "$0") [SINK] [-h] -- connect bluetooth headphones

where:
		-h  show this help text

available audio sinks:
$(pacmd list-sinks | grep "name: ")
"

while getopts ':h' option; do
	case "$option" in
		h) echo "$usage"
			exit
			;;
		\?) printf "illegal option: -%s\n" "$OPTARG" >&2
			echo "$usage" >&2
			exit 1
			;;
	esac
done
shift $((OPTIND - 1))


if [[ "$1" = "mpow" ]]; then
	use_mpow
elif [[ "$1" = "speakers" ]]; then
	use_speakers
fi
