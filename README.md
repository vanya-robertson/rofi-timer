# rofi-timer

A shell script to create and control multiple timers from rofi.  

# Specifications

## Storage

Stored in `$XDG_DATA_HOME/rofi-timers.csv`
Stored in format: `\<UNIX timestamp of date due\>,\<alarm/timer\>,"\<message for notification\>"`

## Entry

New entries must include a timestamp or duration and a description.  
Modifying existing entries can include either a time, a description, or both.  
Viable duration formats are "+MM", "+MM:SS" or "+HH:MM:SS".  
Viable timestamp formats are "HH", "HH:MM" or HH:MM:SS".  
Timestamps are presumed to be on the day of entry if after the current time, or on the day after if before the current time.  
For a new entry, entry of a duration makes entry a timer and entry of a timestamp, an alarm.  
Modification of an existing entry by a duration will append the amount of time specified.  

## Watching and waiting

Upon exiting the modification script with code 0, the background process is spawned.  
If an existing background process exists, it is terminated.  
If the storage file is empty, the process exits.  
This background process waits for the amount of time between the current UNIX time and the UNIX time of the soonest alarm.  
Once complete:  
A sound is played.  
A notification is sent.  
The soonest item is deleted.
The script spawns a new instance of itself, then terminates.  

# Suggested customisations

Start the background script from xinitrc to enable automatic resume after power off.  

# Dependencies

rofi (rofi)  
date (coreutils)  
sponge (moreutils)  
mpv (mpv)
notify-send (libnotify)  
dunst (dunst)  
