# Bash-script
Develop a bash utility script that:
1.	Can generate two different versions of UUID{1,2,3,4,5} without the use of built-in UUID generators:
–	Should be able to save to file AND print to terminal.
–	Check if previous UUID exists and see if collision
–	Check when last UUID was generated
2.	Categorise content in _Directory folder:
–	For each child directory report how many of each file type there and collective size of each file type
–	For each child directory specify total space used, in human readable format
–	For each child directory report find shortest and largest length of file name
–	Output results to file AND option to return to terminal
3.	For all functionality
–	there should be an argument
–	can run functionality per argument(s)
–	Must be able to record who has logged into system and when, and which script commands have been supplied appended to a log file.
4.	Build a simple man page for your script
–	ensure you have compressed the document with gzip and named it with the correct man identifier.
5.	Throughout ensure you have reference to the PID of your script and PID of any sub commands run!
