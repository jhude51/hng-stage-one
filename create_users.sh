#!/bin/bash

# Purpose - A Bash Script that reads a text file containing employee's usernames and group names
#           where each line is formatted as user; groups
# Author  - Dayo Adeyemi, as part of HNG Internship tasks
# --------------------------------------------------------------------------------------------------

# Check if command line argument is provided
[[ -z ${1} ]] && { echo "Argument must be a file and not empty"; exit 1; }

# Check if command line argument provided is a valid or present file
[[ ! -f ${1} ]] && { echo "Can't find the input file. Kindly specify a correct path!"; exit 1; }

# Declare variables

# Input file passed as command line argument declared as a constant
readonly INPUT_FILE="$1"

# Password file to store generated password(s)
PASSWORD_FILE="/var/secure/user_passwords.txt"

# Log file to store all logged actions
LOG_FILE="/var/log/user_management.log"


# Function to generate random password using the built-in RANDOM variable
# The RANDOM variable is numeric by nature. Hence, it is piped to base64 for alphanumeric
password_gen(){
	echo $RANDOM | base64
}

# Function to log messages
logger() {
	echo "$(date '+%d/%m/%Y %H:%M:%S') - $1" >> $LOG_FILE
}

# Ensure generated password is stored securely
mkdir -p /var/secure
chmod 700 /var/secure

make_group() {
	if ! getent group $1 >/dev/null; then
		echo "Group $1 does not exist, Adding it now..."
		groupadd $1
		echo "Group Added"
	fi
}

# Main Script Execution
# Set the default field seperator to newline to read each line  
IFS=$'\n'
while read -r lines; do
	# Iterate over each line
	for line in $lines; do
		# Split the line into an array by the delimiter ; followed by a white space - '; '
		# e.g. light; sudo,dev,www-data becomes [0] = light, [1] = sudo,dev,www-data
		IFS='; ' read -a user <<< "$line"
		# Assign first index to username 
		username="${user[0]}"
		# Assign second index to groups
		groups="${user[1]}"

		#Adding Supplementary Groups if they don't exist 
		if [ -n "$groups" ]; then
			IFS=','
			for group in "$groups"; do
				make_group $group
			done
		fi

		# Check if user already exists. If true, skip
		if id "$username" &>/dev/null; then
			echo "User $username already exists. Skipping..."
		        logger "User $username already exists. Skipped."
	        else
			echo "Creating user $username with the following secondary group(s) $groups."
			logger "Creating user $username with the following secondary group(s) $groups."

			# Function call to password_gen function and assigned to password variable
			password=$(password_gen)
			logger "user $username password generated successfully."

			# Create user with home directory -m, create group with same name as user -U
			# Append secondary groups seperated by comma -G
			useradd -m -U -G $groups $username &>> $LOG_FILE
			
			# Log failure if exit code $? is not 0 i.e. useradd failed
			if [[ $? -ne 0 ]]; then
				logger "Failed to create the user $username."
			fi

			echo "User $username created with the following secondary group(s) $groups."
			logger "User $username created with the following secondary group(s) $groups."

			# Set user password with generated random password variable
			echo "$username:$password" | chpasswd
			logger "Password created for user $username."

			# Store password in the password file
			echo "$username,$password" >> $PASSWORD_FILE
			logger "Password written into $PASSWORD_FILE."
			# Secure password file with u+rw, and no permission for group members and other users
			chmod 600 $PASSWORD_FILE

			# Set permissions for the user's home directory.
			chown "$username":"$username" "/home/$username"
			chmod 700 "/home/$username"
			logger "Appropriate permissions successfully set on home directory of $username"
		fi
	done
# Command line argument file passed as input
done < $INPUT_FILE
echo "User(s) successfully created. For details, see log file at '$LOG_FILE'"
logger "User(s) successfully created."
