#!/bin/sh

# program to activate alarms and delete them when complete


csv_file="$HOME/projects/rofi-timers/test/file.temp"
sound_effect="$HOME/archives/soundeffects/el-hadj-djeli-sory-kouyate/balaphone-ding-2.ogg"
current_unix_time="$(date +%s)"
lockfile="/tmp/rofi-timer/rofi-timer.pid"

play_item() {
  top_line="$(head -n 1 "$csv_file")"
  end_time="$(echo "$top_line" | awk -F ',' '{ print $1}')"
  form="$(echo "$top_line" | awk -F ',' '{ print $2}')"
  message="$(echo "$top_line" | awk -F ',' '{ print $3}')"
  # Wait for the soonest alarm to be finished
  sleep "$(expr "$end_time" - "$current_unix_time")"
  # Play a sound
  mpv --vid=no "$sound_effect" > /dev/null 2>&1 &
  # Send a critical notification
  dunstify --urgency=CRITICAL "$(echo "$form" | sed 's/.*/\u&/') finished" "$message at $(date +%s) instead of $end_time"
  # Delete the first line in the csv file
  sed -i '1d' "$csv_file"
}
# Create new process and corresponding pidfile

#
## Make sure the lockfile is removed when we exit and then claim it
#trap "rm -f $lockfile; exit" INT TERM EXIT
[ -d /tmp/rofi-timer ] || mkdir /tmp/rofi-timer/
# If pidfile present
if [ -f "$lockfile" ]; then
  dunstify "already running"
  # Kill last process
  kill -0 "$(cat $lockfile)"
  # Replace pid
  echo $$ > $lockfile
  # Wait
  # Notify
  # Delete
  [ -s "$csv_file" ] && play_item
  # Remove pidfile
  rm -f $lockfile
# If pidfile absent
else
  dunstify "not running"
  # Make pid
  echo $$ > $lockfile
  # Wait
  # Notify
  # Delete
  [ -s "$csv_file" ] && play_item
  # Remove pidfile
  rm -f $lockfile
fi

##exit 0
## Spawn new process
##sh /home/jcrtf/projects/rofi-timers/rofi-timer-bg.sh
