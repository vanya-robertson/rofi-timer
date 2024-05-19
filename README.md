# rofi-timers

Shell script to create and control multiple timers from rofi  
Work in progress  

# Specifications

- Timers stored in $XDG_DATA_HOME/rofi-timers.csv
- rofi-timers.csv will be in the format:

> \<UNIX timestamp of date due\>,\<alarm/timer\>,"\<message for notification\>"

- rofi permits entry of alarms in format "HH:MM:SS", "HH:MM" or "MM"
- rofi permits entry of duration of a timer in format "+HH:MM:SS", "+HH:MM" or "+MM"  
- rofi displays existing alarms as "at \<time\>" and existing timers as "\<time\> left" 

- upon triggering an alarm
    + a sound will be played
    + a notification will be sent with title "\<Alarm/Timer\> complete" "\<message for notification\>"

- upon exiting the rofi menu, rofi-timers.csv will be sorted by "UNIX timestamp of date due"
- after this, a process will be made to wait for the difference between current date and UNIX timestamp of date due, then play the noise and display the notification
- if this process is completed, the top line in the file is deleted, and a new process is created for the next soonest alarm or timer
- if rofi-timers.csv is empty, no process is created

# Potential additions

- create line for xinitrc to start counting down top line.

# Dependencies

rofi (rofi)  
date (coreutils)  
sponge (moreutils)
mpv (mpv)  
dunstify (dunst)  
dunst (dunst)  
sec-to-flex (personal python script)  
flex-to-sec (personal python script)  
