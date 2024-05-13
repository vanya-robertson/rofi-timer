#!/bin/sh

# program to make and edit alarms via rofi.

csv_file="test/file.temp"
sound_effect="$HOME/archives/soundeffects/batman.opus"

# read data file
# for each item:
# - generate a human-readable string (from type, time to end and message) and append to a variable
#   + this string shall be piped into rofi, providing the selection interface
# - generate a variable whose name maps onto the eventual rofi output
#   + and whose value is the entire string representing the timer/alarm

menu_count=0
menu_string=""

while IFS="," read -r end_time type message
do
  [ "$(echo "$type" | tr '[:upper:]' '[:lower:]')" = "alarm" ] && output_as_string="Alarm ending at $(date -d @"$end_time" -u +%Y-%m-%dT%H:%M:%S): $message"
  [ "$(echo "$type" | tr '[:upper:]' '[:lower:]')" = "timer" ] && output_as_string="Timer ending in $(sec-to-flex $((end_time - $(date +%s)))): $message"
  [ "$menu_count" = 0 ] && menu_string="$menu_string$output_as_string"
  [ "$menu_count" -gt 0 ] && menu_string="$menu_string\n$output_as_string"
  menu_count=$((menu_count+1))
  output_as_variable="$(echo "$output_as_string" | tr -d '[:punct:]' | tr ' ' '_')"
  eval "$output_as_variable"="'$end_time,$type,$message'"
#  echo "$output_as_variable: $end_time,$type,$message"
done < "$csv_file"

# take menu_string and select line with rofi
# if first_output is in a format beginning with "Alarm" or "Timer", it originates from the menu
# - new input is required to alter the time and/or message of the alarm/timer.
# - independently generate another string (text_as_variable) whose value is generated in the same way as output_as_variable above
# - evaluate this string as a variable, giving the value of the value of output_as_variable: the line representing the timer/alarm
# - find the number of the line with this value in the csv file
# if first_output starts with a + or numbers, it is a new alarm, and shall be used to generate a new entry in the csv file
# - if first_output starts with a +, it is a timer
# - if first_output starts with numbers, it is an alarm

current_unix_time="$(date +%s)"
today_unix_time="$(date -d "$(date +%Y-%m-%dT00:00:00Z)" +%s)"

first_output="$(echo "$menu_string" | rofi -dmenu)"
if echo "$first_output" | grep -qe '^Alarm' -e '^Timer' ; then
  text_as_variable=$(echo "$first_output" | tr -d '[:punct:]' | tr ' ' '_')
  # echo "text_as_variable is $text_as_variable"
  timer_id="$(eval echo "\$$text_as_variable")"
  echo "timer_id is $timer_id"
  corresponding_line_number="$(sed -n "/$timer_id/{=;q;}" "$csv_file")"
#  echo "corresponding_line_number is $corresponding_line_number"
  second_output=$(rofi -dmenu -l 0)
#  echo "$second_output"
  if echo "$second_output" | grep -Pq '^\+?(\d\d:){0,2}\d\d(?!:|\d)'; then
    proto_new_end_time=$(echo "$second_output" | grep -oP "^[^\s]*")
    proto_new_message=$(echo "$second_output" | grep -oP "(?<= ).*")
#    echo "proto_new_end_time is $proto_new_end_time"
#    echo "proto_new_message is $proto_new_message"
  elif echo "$second_output" | grep -Pq '^\w'; then
    proto_new_message="$second_output"
    echo "proto_new_message is $proto_new_message"
    # here, append new entry to output file
  fi
else
  echo "this is new"
  proto_new_end_time=$(echo "$first_output" | grep -oP "^[^\s]*")
  proto_new_message=$(echo "$first_output" | grep -oP "(?<= ).*")
  if echo "$first_output" | grep -Pq '^\+(\d\d:){0,2}\d\d(?!:|\d)'; then
    new_type="timer"
  elif echo "$first_output" | grep -Pq '^(\d\d:){0,2}\d\d(?!:|\d)'; then
    new_type="alarm"
  fi
fi

echo "$timer_id" |
#sed "$corresponding_line_number!d;q" "$csv_file" |
while IFS="," read -r end_time type message
do
  echo "timer_id is $end_time,$type,$message"
  if [ -z "$proto_new_end_time" ]; then
    new_end_time="$end_time"
  elif echo "$proto_new_end_time" | grep -Pq "^\+.+"; then
    echo "branch 1"
    echo "proto_new_end_time is $proto_new_end_time"
    echo "truncated version of proto_new_end_time is $(echo "$proto_new_end_time" | tr -d "+")"
    echo "flex-to-sec version of "
    new_end_time="$(expr "$end_time" + "$(flex-to-sec "$(echo "$proto_new_end_time" | tr -d "+")")")"
  else
    echo "branch 2"
    new_end_time="$(expr "$today_unix_time" + "$(flex-to-sec "$proto_new_end_time")")"
    if [ "$new_end_time" -le "$current_unix_time" ]; then
      new_end_time="$(expr "$new_end_time" + 86400)"
    fi
  fi
  if [ -n "$proto_new_message" ]; then
    new_message=\"$proto_new_message\"
  else
    new_message=$message
  fi
  if [ -z "$new_type" ]; then
    new_type=$type
  fi
  echo "output   is $new_end_time,$new_type,$new_message"
#  sed "$corresponding_line_number""s/.*/$new_end_time,$new_type,$new_message" "$csv_file"
  sort "$csv_file" | sponge "$csv_file"
done
#
#
#head -n 1 "$csv_file" |
#while IFS="," read -r end_time type message
#do
#  sleep "$(expr "$end_time" - "$current_unix_time")"
#  echo "$new_end_time,$type,$new_message"
##  mpv --vid=no "$sound_effect"
##  dunstify --urgency=CRITICAL "$(echo "$type" | sed 's/.*/\u&/') finished" "$(sec-to-flex "$1")"
##  sed -i '1d' "$csv_file"
#done

# sort the file (by the end time)
# refresh the timer (to the top alarm in the file: the soonest) upon editing the file

# if the csv file is not empty
# - wait for the soonest alarm to be finished
# - if the current time is less than or equal to the end time:
#   + play a sound
#   + send a critical notification
#   + delete the first line in the csv file
#   + restart this process

# bonus: put this function in your xinitrc or equivalent
