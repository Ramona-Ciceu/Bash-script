#! /usr/bin/env bash

# Getting the PID of the script
SCRIPT_PID=$$

#Function to generate UUID version 3
generate_uuid_v3(){
     local NAMESPACE="$1"
     local NAME="$2"

     md5=$(echo -n "${NAMESPACE}${NAME}" | md5sum | awk '{print $1}')
     echo "${md5:0:8}-${md5:8:4}-${md5:12:4}-${md5:16:4}-${md5:20:12}"
}

#Function to generate UUID version 5
generate_uuid_v5(){
    local NAMESPACE="$1"
    local NAME="$2"


    sha1=$(echo -n "{$NAMESPACE}${NAME}" | sha1sum | awk '{print $1}')
    echo "${sha1:0:8}-${sha1:8:4}-${sha1:12:4}-${sha1:16:4}-${sha1:20:12}"
}

#Function to check if UUID exists and detect collisions
check_collision(){
   local UUID="$1"
   
   if [ -e "uuids.txt" ] && [ -f "uuids.txt" ]; then
      if grep -Fxq "$UUID" uuids.txt; then
        echo "Collision detected: $UUID"
      fi
   fi 
}


#Function to save UUID to file
save_to_file(){
  local UUID="$1"
  echo "$UUID" >> uuids.txt
}


#Function to print UUID and last generated time
print_uuid(){
  local UUID="$1"
  echo "UUID: $UUID"
  echo "Last generated: $(date)"
}

# Parsing command line options
while getopts ":l:" opt; do
    case ${opt} in
    l)  # Specify log file
        log_file="${OPTARG}"
        if [ ! -f "$log_file" ]; then
            echo "Log file does not exist. Creating a new one..."
            touch "$log_file" || { echo "Error creating log file." >&2; exit 1; }
        fi
        ;;
    \?)
        echo "Invalid option: ${OPTARG}" >&2
        exit 1
        ;;
    :)
        echo "Invalid option: ${OPTARG} requires an argument" >&2
        exit 1
        ;;
    esac
done
shift $((OPTIND -1))

#Generating UUID version 3
NAMESPACE="namespace"
UUID3=$(generate_uuid_v3 "$NAMESPACE" "name3")

#Generating UUID version 5
UUID5=$(generate_uuid_v5 "$NAMESPACE" "name3")


#Checking for collision and save to file for UUID3 and UUID5
check_collision "$UUID3"
save_to_file "$UUID3"
print_uuid "$UUID3"

check_collision "$UUID5"
save_to_file "$UUID5"
print_uuid "$UUID5"

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

    # Returning to the original directory
    cd - > /dev/null || exit
}

# Function to log user login and script commands
log_commands() {
    local log_file="script_log.txt"
    echo "User: $(whoami)" >> "$log_file"
    echo "Login time: $(date)" >> "$log_file"
    echo "Commands: $*" >> "$log_file"
    echo "---------------------------------------" >> "$log_file"
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
main "_Directory/subdirectory_1" "_Directory/subdirectory_2" "_Directory/subdirectory_3" "_Directory/subdirectory_4" 

# Getting the PID of the script
echo "PID of the script: $SCRIPT_PID"

