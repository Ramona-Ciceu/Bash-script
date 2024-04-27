#! /usr/bin/env bash

# Getting the PID of the script

SCRIPT_PID=$$

#Function to check if UUID exists and detect collisions

check_collision(){

	local UUID="$1"

	if [ -e "uuids.txt" ] && [ -f "uuids.txt" ]; then

	if grep -Fxq "$UUID" uuids.txt; then

	echo "Collision detected: $UUID"

	fi

	fi

}

#Function to generate UUID version 3

generate_uuid_v3(){
	randomName=$(echo -n "$name" | tr '[:upper:]' '[:lower:]')
	randomNamespace=$(dd if=/dev/random count=16 bs=1 2> /dev/null | xxd -ps)

	md5=$(echo -n "${randomNamespace}${randomName}" | md5sum | awk '{print $1}')

	uuid3="${md5:0:8}-${md5:8:4}-${md5:12:4}-${md5:16:4}-${md5:20:12}"

	echo "UUID: $uuid3"

	echo "Last generated: $(date)"

	#Checking for collision and save to file for UUID3 and UUID5

	check_collision "$uuid3"
	echo "$uuid3" >> uuids.txt
}

#Function to generate UUID version 5

generate_uuid_v5(){
       
	randomName=$(echo -n "$name" | tr '[:upper:]' '[:lower:]')
	randomNamespace=$(dd if=/dev/random count=16 bs=1 2> /dev/null | xxd -ps)


	sha1=$(echo -n "${randomNamespace}${randomName}" | sha1sum | awk '{print $1}')
	
	uuid5="${sha1:0:8}-${sha1:8:4}-${sha1:12:4}-${sha1:16:4}-${sha1:20:12}"


	echo "UUID: $uuid5"

	echo "Last generated: $(date)"

	
	check_collision "$uuid5"
	
	echo "$uuid5" >> uuids.txt

}

# Function to categorise content in each child directory

categorise_content() {

	local directory="$1"

	# Navigating to the directory

	cd "$directory" || { echo "Error: Unable to access directory $directory"; exit 1; }

	# Initialising variables

	declare -A file_counts

	declare -A file_sizes
	
	shortest_filename=""

	longest_filename=""

	total_space_used=0

	# Loop through files in the _Directory

	while IFS= read -r file; do

	# Checking if the file exists

	if [ -f "$file" ]; then

	# Count file types

	file_type="${file##*.}"

	(( file_counts["$file_type"]++ ))

	# Calculating file sizes

	file_size=$(stat -c %s "$file")
	
	(( file_sizes["$file_type"] += file_size ))

	# Updating shortest and longest filenames

	if [[ -z $shortest_filename ]] || (( ${#file} < ${#shortest_filename} )); then

	shortest_filename="$file"
	
	fi
	
	if [[ -z $longest_filename ]] || (( ${#file} > ${#longest_filename} )); then

	longest_filename="$file"

	fi

	# Updating total space used

	(( total_space_used += file_size ))

	fi

	done < <(find . -type f)
	# Outputing the results for

	#arranged directories.

	echo "Directory: $directory"

	echo "File type counts:"

	for type in "${!file_counts[@]}"; do

	echo "$type: ${file_counts[$type]}"

	done

	echo "Total space used: $(numfmt --to=iec $total_space_used)"

	echo "Shortest filename: $shortest_filename"

	echo "Longest filename: $longest_filename"

	#Checking if the variable ls_option is set to "true"

	if [ "$ls_option" = "true" ]; then

	# If ls_option is true, display a message indicating the

	#listing files in the directory.

	echo "Files in directory:"

	# List the files in long format

	ls -l

	fi
	
	if [ -d "$file" ]; then 
		((subdirectory++))
	fi 
	
	for sub in $subdirectory; do 
		categorise_content
		
	done 
		
	# Returning to the original directory

	cd - > /dev/null || exit

}

# Main function that logs the login along with script commands

# and detecting/analysing the directories.

main() {

log_commands "$@"

# Checking for arguments

if [ "$#" -eq 0 ]; then

echo "Usage: $0 <directory>"

exit 1

fi

for directory in "$@"; do

categorise_content "$directory"

done

}

# Calling the main function
run(){
main "_Directory/subdirectory_1" "_Directory/subdirectory_2" "_Directory/subdirectory_3" "_Directory/subdirectory_4" "_Directory/subdirectory_5" 2> /dev/null 
}
save_to_logFile(){
	run > $logfile
}

# Getting the PID of the script

echo "PID of the script: $SCRIPT_PID"	
# Parsing command line options

while getopts ":35l:p:" opt; do

	case ${opt} in


		3) # Flag to create a uuidv3

		generate_uuid_v3

		#log_commands +='-3'

		;;

		5) # Flag to create a uuidv5

		generate_uuid_v5

		#log_commands +='-5'
		;; 
		p) #actally the print flag 
		run
		;;
	
	 esac
 done
# take the logfile from user then save to that one (simple redirect) 
#change the c to the print to screen/ vebrose 
