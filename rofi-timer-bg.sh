#!/bin/sh

# program to activate alarms and delete them when complete

csv_file="$XDG_DATA_HOME/rofi-timer.csv"
sound_effect="$HOME/archives/soundeffects/el-hadj-djeli-sory-kouyate/balaphone-ding-2.ogg"
current_unix_time="$(date +%s)"
lockfile="/tmp/rofi-timer/rofi-timer.pid"

# If pidfile not empty, exit process
[ -e "$lockfile" ] && kill "$(cat "$lockfile")"
[ -z "$(cat "$csv_file")" ] && exit 0
[ -d "$(dirname "$lockfile")" ] || mkdir -p "$(dirname "$lockfile")"
echo $$ > "$lockfile"

top_line="$(head -n 1 "$csv_file")"
end_time="$(echo "$top_line" | awk -F ',' '{ print $1}')"
form="$(echo "$top_line" | awk -F ',' '{ print $2}')"
message="$(echo "$top_line" | awk -F ',' '{ print $3}')"
sleep "$(expr "$end_time" - "$current_unix_time")"
rm -f "$lockfile"
notify-send --urgency=CRITICAL "$(echo "$form" | sed 's/.*/\u&/') finished" "$message"
mpv --vid=no "$sound_effect" > /dev/null 2>&1
#ffplay -nodisp -autoexit "$sound_effect" > /dev/null 2>&1
nohup rofi-timer-bg.sh > /dev/null &
sed -i '1d' "$csv_file"
