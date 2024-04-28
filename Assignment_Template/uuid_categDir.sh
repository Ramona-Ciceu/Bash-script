#! /usr/bin/env bash

# Getting the PID of the script

SCRIPT_PID=$$

#Function to check if UUID exists and detect collisions

check_collision(){

       # Storing the UUID passed as an argument

	local UUID="$1"

     # Checking if the "uuids.txt" file exists and is a regular file

	if [ -e "uuids.txt" ] && [ -f "uuids.txt" ]; then

     # Using grep to search for an exact match of the UUID in the "uuids.txt" file

	if grep -Fxq "$UUID" uuids.txt; then

     # Outputting a message indicating a collision is detected  

	echo "Collision detected: $UUID"

	fi

	fi

}

#Function to generate UUID version 3

generate_uuid_v3(){
       # Generating a random name and converting it to lowercase

	randomName=$(echo -n "$name" | tr '[:upper:]' '[:lower:]')
         
        #Generating  random namespace
         
	randomNamespace=$(dd if=/dev/random count=16 bs=1 2> /dev/null | xxd -ps)

       # Concatenating random name and namespace, then generating MD5 hash

	md5=$(echo -n "${randomNamespace}${randomName}" | md5sum | awk '{print $1}')

       # Formatting the UUID version 3

	uuid3="${md5:0:8}-${md5:8:4}-${md5:12:4}-${md5:16:4}-${md5:20:12}"

       # Outputting the generated UUID and the timestamp

	echo "UUID: $uuid3"

	echo "Last generated: $(date)"

	#Checking for collision and save to file for UUID3 

	check_collision "$uuid3"
	echo "$uuid3" >> uuids.txt
}

#Function to generate UUID version 5

generate_uuid_v5(){
       
        # Generating a random name and converting it to lowercase

	randomName=$(echo -n "$name" | tr '[:upper:]' '[:lower:]')

        #Generating  random namespace

	randomNamespace=$(dd if=/dev/random count=16 bs=1 2> /dev/null | xxd -ps)

       # Concatenating random name and namespace, then generating MD5 hash

	sha1=$(echo -n "${randomNamespace}${randomName}" | sha1sum | awk '{print $1}')

       # Formatting the UUID version 5
	
	uuid5="${sha1:0:8}-${sha1:8:4}-${sha1:12:4}-${sha1:16:4}-${sha1:20:12}"


       # Outputting the generated UUID and the timestamp

	echo "UUID: $uuid5"

	echo "Last generated: $(date)"

	
      #Checking for collision and save to file for UUID5

	check_collision "$uuid5"
	
	echo "$uuid5" >> uuids.txt

}

# Function to categorise content in each child directory

categorise_content() {
 
     # Storing the directory passed as an argument

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


       # Extracting file type from the file extension

	file_type="${file##*.}"


       # Incrementing file type count

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

	# Outputting the results for categorised directories.

	echo "Directory: $directory"

	echo "File type counts:"

	for type in "${!file_counts[@]}"; do

	    echo "$type: ${file_counts[$type]}"

	done

	echo "Total space used: $(numfmt --to=iec $total_space_used)"

	echo "Shortest filename: $shortest_filename"

	echo "Longest filename: $longest_filename"

     
      # Checking for subdirectories 
	
	if [ -d "$file" ]; then 
		((subdirectory++))
	fi 
	
     # Calling categorise_content for subdirectories	

	for sub in $subdirectory; do 
		categorise_content
		
	done 
		
     # Returning to the original directory

	cd - > /dev/null || exit

}

# Function to log user login and script commands
log_commands() {

  # Defining the log file
    local log_file="script_log.txt"

  # Log the current user's username 
    echo "User: $(whoami)" >> "$log_file"

  # Log the login time
    echo "Login time: $(date)" >> "$log_file"

  # Log the script commands
    echo "Commands: $*" >> "$log_file"

  # Adding separator for clarity
    echo "---------------------------------------" >> "$log_file"
}

# Main function that logs the login along with script commands

# and detecting/analysing the directories.

main() {

# Log the user login and script commands

  log_commands "$@"

# Checking for arguments

  if [ "$#" -eq 0 ]; then

  echo "Usage: $0 <directory>"

  exit 1

  fi

# Iterate over each directory argument

  for directory in "$@"; do
     # Call categorise_content function for each directory
      categorise_content "$directory"

  done

}

# Calling the main function
run(){
main "_Directory/subdirectory_1" "_Directory/subdirectory_2" "_Directory/subdirectory_3" "_Directory/subdirectory_4" "_Directory/subdirectory_5" 2> /dev/null 
}

 # function to save the output of 'run' function to a log file
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
		;;

		5) # Flag to create a uuidv5
		generate_uuid_v5
		;; 
  
		p) # Printing flag 
		run
		;;
  
		l) # Flag to specify the logfile
		logfile="$OPTARG"
		;;
	 esac
 done

 # If logfile is not specified, default to "logfile.txt"

if [ -z "$logfile" ]; then
    logfile="logfile.txt"
fi

# Redirecting the output to the log file
run > "$logfile" 2> /dev/null


