#!/bin/zsh
# mount drive when iTunes launches
#
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Date:	2013-03-14

# `msg` is explained/available here: https://github.com/tjluoma/msg


	# This is the name of the external drive that your iTunes database lives on.
	# do NOT include the /Volumes/ part
DRIVE_NAME='Audio-DroboFW'

#
# 		If you wanted to be fancy you could try to detect this automatically
#
# fgrep '<key>Music Folder</key>' "$HOME/Music/iTunes/iTunes Music Library.xml"
#
# fgrep '<key>Music Folder</key>' "$HOME/Music/iTunes/iTunes Library.xml"
#
#		but I don't feel the need to be that fancy
#
####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
#
#
#	You should not have to edit anything below this line
#

NAME="$0:t"

MNT_PNT="/Volumes/$DRIVE_NAME"

GROWL_APP="iTunes"	# this is used for 'msg'

if (( diskutil list -plist | fgrep -A1 '<key>MountPoint</key>' | fgrep -q "<string>/Volumes/$DRIVE_NAME</string>" ))
then

	# I found it annoying to have the alert appear every time that the drive is verified to be active
	# msg "$DRIVE_NAME is mounted"
	exit 0

fi

	# pgrep is standard in 10.8 but not earlier. Get it from luo.ma/brew if you don't have it

if ((! $+commands[pgrep] ))
then

	# note: if pgrep is a function or alias, it will come back not found

	echo "$NAME: pgrep is required but not found in $PATH"
	exit 1
fi


	# This will give us the PID of iTunes (NOT iTunes Helper) if it exists
PID=$(pgrep -x iTunes)

if [[ "$PID" == "" ]]
then

			# if iTunes is not running right now we won't need to pause it and resume it later

		RESUMEITUNES=no
else

			# if we get here then iTunes IS running now and we need to pause it
			# so we can mount the drive

		RESUMEITUNES=yes

			# kill -STOP won't actually 'kill' iTunes, it will just 'freeze' it until we are ready for it
			# iTunes will be non-responsive during this time, but that's OK
		kill -STOP "$PID" && \
			GROWL_ID=killitunes && \
				GROWL_APP=iTunes && \
					msg sticky "Paused iTunes"
fi


while [[ ! -d "$MNT_PNT" ]]
do

		# Note: this will keep trying forever or until the drive is mounted where expected

		msg sticky "Trying to mount $DRIVE_NAME at `timestamp`"

			# NOTE: we do NOT want to use MNT_PNT here just the DRIVE_NAME
		diskutil mount "$DRIVE_NAME"
done


if [[ -d "$MNT_PNT" ]]
then
			# The drive is mounted
		msg "$MNT_PNT is mounted"

		if [[ "$RESUMEITUNES" == "yes" ]]
		then

					# If we paused iTunes before we will now try to resume it (kill -CONT)

				kill -CONT "$PID" && \
					GROWL_ID=killitunes && \
						GROWL_APP=iTunes && \
							msg "UN-paused iTunes"

		fi

		exit 0
fi


	# if we get here something went wrong
exit 1

#
#EOF
