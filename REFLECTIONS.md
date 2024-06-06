# Technique

I have learned that input sanitation saves effort in the long-run.  
This is my first program using exit codes, forking and PID files.  

# Style

This program has taught me about the importance of readable code and the role functions play in this.  
Even if the function ends up being incorporated into the main body, it provides a medium-to-long-term memory aid, compartmentalising and representing chunks of logic.  

# Questions

Is the improved performance of `[ expression ] &&` relative to readability of if statements justified for medium-complexity clauses?  
Is `[ expression ] &&` faster than a switch statement?  
Is there a way to implement the functionality of sponge natively in POSIX?  
Does it make sense to:  
a) Disable the entry of a timestamp into an existing timer?  
b) Presume that entry of a timestamp must be a mistake, and treat it as a duration?  
c) Leave the functionality whereby a timer can be modified by a timestamp?  
