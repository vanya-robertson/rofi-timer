# rofi-timers

Shell script to create and control multiple timers from rofi  
Work in progress  

# Specifications

- Timers stored in $XDG_DATA_HOME/rofi-timers.csv
- rofi-timers.csv will be in the format:

> \<UNIX timestamp of date created\>,\<UNIX timestamp of date due\>,\<Alarm/Timer\>,"\<message for notification\>"

- rofi permits entry of alarms in format "((DD )HH(:))MM((:)SS)"
- rofi permits entry of duration in format "+((DD )HH(:))MM((:)SS)"  
- rofi displays existing alarms (as "((DD )HH(:))MM((:)SS)") and durations (as countdowns in format ((DD )HH(:))MM((:)SS))
- the countdowns will be obvious because they will be counting down, refreshing every second

- upon triggering an alarm
    + a sound (batman.opus) will be played
    + a notification will be sent with title "\<Alarm/Timer\> complete" "\<message for notification\>"

- upon exiting the rofi menu, rofi-timers.csv will be sorted by "UNIX timestamp of date due"
- after this, a process will be made to wait for the difference between current date and UNIX timestamp of date due, then play the noise and display the notification
- if this process is completed, the top line in the file is deleted, and a new one is created for the new top one
- if rofi-timers.csv is empty, no process is created

# Potential addition

- create line for xinitrc to start counting down top line.

# Dependencies

rofi (rofi) 
date (coreutils)
mpv (mpv)
dunstify (dunst)
dunst (dunst)
