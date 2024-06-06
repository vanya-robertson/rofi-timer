#!/bin/sh

# program to make, edit and delete alarms via rofi.

csv_file="$XDG_DATA_HOME/rofi-timer.csv" # ensure this variable is the same as in rofi-timer-bg.sh
today_unix_time="$(date -d "$(date +%Y-%m-%dT00:00:00Z)" +%s)"

#debug() {
#  notify-send "$1"
#}

timezone_rectification() {
  pro_sign="$(date +%:z | cut --characters 1)"
  [ "$pro_sign" = "-" ] && sign="+"
  [ "$pro_sign" = "+" ] && sign="-"
  hours="$(date +%:z | cut --characters 2-3)"
  minutes="$(date +%:z | cut --characters 5-6)"
  timezone_modification="$(expr "$hours" \* 3600 + "$minutes" \* 60)"
  current_unix_time="$(date +%s)"
  new_end_time="$(echo "$today_unix_time" + "$(convert_timestamp_to_seconds "$proto_new_end_time")" "$sign" "$timezone_modification" | bc)"
  [ "$new_end_time" -le "$current_unix_time" ] &&
    new_end_time="$(expr "$new_end_time" + 86400)"
}

check_input_time_type() {
  echo "$1" | grep -Pq '^\+(\d\d:){0,2}\d\d(?!:|\d)' &&
    proto_time_type="duration"
  echo "$1" | grep -Pq '^(\d\d:){0,2}\d\d(?!:|\d)' &&
    proto_time_type="timestamp"
}

input_error() {
  notify-send "rofi-timer" "Incorrect input"
  exit 1
}

delete_item() {
    sed -i "$line_number d" "$csv_file" &&
    notify-send "$(echo "$time_type" | sed 's/.*/\u&/') deleted" &&
    rofi-timer-bg.sh &
    exit 0
}

[ -e "$csv_file" ] || touch "$csv_file"

convert_duration_to_seconds() {
  hours=0
  minutes=0
  seconds=0
  if echo "$1" | grep -Pq '^[0-9]+:[0-9][0-9]:[0-9][0-9]$'; then
    hours="$(echo "$1" | awk -F ':' '{ print $1}')"
    minutes="$(echo "$1" | awk -F ':' '{ print $2}')"
    seconds="$(echo "$1" | awk -F ':' '{ print $3}')"
  elif echo "$1" | grep -Pq '^[0-9]+:[0-9][0-9]$'; then 
    minutes="$(echo "$1" | awk -F ':' '{ print $1}')"
    seconds="$(echo "$1" | awk -F ':' '{ print $2}')"
  elif echo "$1" | grep -Pq '^[0-9]+$'; then
    minutes="$(echo "$1" | awk -F ':' '{ print $1}')"
  fi
  expr 3600 \* "$hours" + 60 \* "$minutes" + "$seconds"
}

convert_timestamp_to_seconds() {
  hours=0
  minutes=0
  seconds=0
  if echo "$1" | grep -Pq '^[0-9]+:[0-9][0-9]:[0-9][0-9]$'; then
    hours="$(echo "$1" | awk -F ':' '{ print $1}')"
    minutes="$(echo "$1" | awk -F ':' '{ print $2}')"
    seconds="$(echo "$1" | awk -F ':' '{ print $3}')"
  elif echo "$1" | grep -Pq '^[0-9]+:[0-9][0-9]$'; then 
    hours="$(echo "$1" | awk -F ':' '{ print $1}')"
    minutes="$(echo "$1" | awk -F ':' '{ print $2}')"
  elif echo "$1" | grep -Pq '^[0-9]+$'; then
    hours="$(echo "$1" | awk -F ':' '{ print $1}')"
  fi
  expr 3600 \* "$hours" + 60 \* "$minutes" + "$seconds"
}

prepend_zeros() {
  var_val="$(eval echo "\$$1")"
  [ ${#var_val} = 1 ] && eval "$1"="0$var_val"
}

convert_from_seconds() {
  remaining_seconds="$1"
  hours=$(expr "$remaining_seconds" / 3600)
  prepend_zeros 'hours'
  remaining_seconds=$(expr "$remaining_seconds" - "$hours" \* 3600)
  minutes=$(expr "$remaining_seconds" / 60)
  prepend_zeros 'minutes'
  remaining_seconds=$(expr "$remaining_seconds" - "$minutes" \* 60)
  prepend_zeros 'remaining_seconds'
  output="$hours:$minutes:$remaining_seconds"
  echo "$output" | grep -q '-' && output="EXPIRED"
  echo "$output"
}

# Generate list of existing entries
menu_count=0
menu_string=""
# For each item in the data file:
while IFS="," read -r end_time type message
do
  # Generate the human-readable string that is used for the menu
  [ "$(echo "$type" | tr '[:upper:]' '[:lower:]')" = "alarm" ] &&
    output_as_string="Alarm at $(date -d @"$end_time"): $message"
  [ "$(echo "$type" | tr '[:upper:]' '[:lower:]')" = "timer" ] &&
    output_as_string="Timer ending in $(convert_from_seconds $((end_time - $(date +%s)))): $message"
  [ "$menu_count" = 0 ] &&
    menu_string="$menu_string$output_as_string"
  [ "$menu_count" -gt 0 ] &&
    menu_string="$menu_string\n$output_as_string"
  menu_count=$((menu_count+1))
  # And generate unique variables containing the whole line's value
  output_as_variable="$(echo "$output_as_string" | tr -d '[:punct:]' | tr ' ' '_')"
  eval "$output_as_variable"="$end_time,$type,\\\"$message\\\""
done < "$csv_file"

# Select a line from the list of existing entries, or enter a new alarm or timer
first_output="$(echo "$menu_string" | rofi -dmenu -l 5)"
[ "$?" = 1 ] && exit 0

# Check novelty: Values may be either new, or existing
echo "$first_output" | grep -qe '^Alarm' -e '^Timer' && novelty="existing"
echo "$first_output" | grep -qe '^+[0-9]' -e '^[0-9]' && novelty="new"

if [ "$novelty" = "existing" ]; then
  var_from_menu="\"$(echo "$first_output" | tr -d '[:punct:]' | tr ' ' '_')\""
  timer_id=$(eval echo "$(eval echo "\$$var_from_menu")")
  line_number="$(sed -n "/$timer_id/{=;q;}" "$csv_file")"
  second_output=$(rofi -dmenu -l 0)
  end_time="$(echo "$timer_id" | awk -F ',' '{ print $1}')"
  time_type="$(echo "$timer_id" | awk -F ',' '{ print $2}')"
  message="$(echo "$timer_id" | awk -F ',' '{ print $3}')"

  # Check whether instruction is to delete
  [ "$second_output" = "delete" ] &&
    delete_item
  [ "$second_output" = "del" ] &&
    delete_item

  check_input_time_type "$second_output"
  if echo "$second_output" | grep -qe '^+' -e '^[0-9]'; then
    new_message="$(echo "$second_output" | grep -oP "(?<= ).*")"
    proto_new_end_time=$(echo "$second_output" | grep -oP "^[^\s]*")
    case "$proto_time_type" in
      'duration')
	new_end_time="$(expr "$end_time" + "$(convert_duration_to_seconds "$(echo "$proto_new_end_time" | tr -d "+")")")"
	;;
      'timestamp')
	timezone_rectification
	;;
    esac
  else
    new_message="$second_output"
  fi
elif [ "$novelty" = "new" ]; then
  echo "$first_output" | grep -Pq '^\+?(\d\d:){0,2}\d\d(?!:|\d) \w' ||
    input_error
  check_input_time_type "$first_output"
  proto_new_end_time=$(echo "$first_output" | grep -oP "^[^\s]*")
  case "$proto_time_type" in
    'duration')
      time_type="timer"
      current_unix_time="$(date +%s)"
      new_end_time="$(expr "$current_unix_time" + "$(convert_duration_to_seconds "$(echo "$proto_new_end_time" | tr -d "+")")")"
      ;;
    'timestamp')
      time_type="alarm"
      timezone_rectification
      ;;
  esac
  proto_new_message=$(echo "$first_output" | grep -oP "(?<= ).*")
  [ -n "$proto_new_message" ] &&
    new_message="$proto_new_message" ||
    new_message="$message"
else
  input_error
fi

[ -n "$new_end_time" ] && end_time="$new_end_time"
[ -n "$new_message" ] && message="\"$(echo "$new_message" | sed 's/"/\\"/g')\""

# Output
[ -n "$line_number" ] &&
  sed -i "$line_number s/.*/$end_time,$time_type,$message/" "$csv_file" ||
  echo "$end_time,$time_type,$message" >> "$csv_file"
sort "$csv_file" | sponge "$csv_file"

rofi-timer-bg.sh &
