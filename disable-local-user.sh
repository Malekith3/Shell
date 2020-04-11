#!/bin/bash
#The Script disables , deletes ,and/or archives users on the local system

#Usage function displaying rules of script . Will call on error 

ARCHIVE_DIR="/archive"

usage(){
	echo "Usage: ${0} [-dra] USER_NAME [USERN]..." >&2
	echo '     USER_NAME Disables (expires/locks) accounts by default' >&2
	echo '	-d USER_NAME Deletes accounts insted of disabling them' >&2
	echo '	-r USER_NAME Removes the home directory associated with the account(s).' >&2
	echo '	-a USER_NAME Creates an archive of the home directory associated with the accounts(s) and stores the archive in the /archives directory.' >&2
	exit 1

}
checking_UID(){

	if [[ $(id -u "$USER_NAME") -lt 1000 ]]; then
		echo "Cannot delete  users with UID less than 1000">&2
	exit 1
	fi
}
delete_user(){
	checking_UID	
	sudo userdel "$USER_NAME"
	if [[ "${?}" -ne 0 ]] ; then
		return 1
	else
		return 0
	fi

}
remove_folder(){
#Function tha deleting user and his folder in /home dir 
	checking_UID
	sudo userdel -r "$USER_NAME"
	if [[ "${?}" -ne 0 ]] ; then
		return 1
	else
		return 0
	fi
}
backup_user(){
#Fucntion make backup of user appropriate folder in /home dir
	checking_UID 
	if [[ ! -d "${ARCHIVE_DIR}" ]] 
	then
		echo "Creating ${ARCHIVE_DIR} directory"
		mkdir -p "/archive"

		if [[ "${?}" -ne 0 ]]; then
			echo "The archive directory ${ARCHIVE_DIR} could not be created." >&2
			exit 1
		fi	
	fi

	sudo tar -czf   "${ARCHIVE_DIR}/${USER_NAME}.tar.gz"   "/home/${USER_NAME}/" &> /dev/null

	if [[ "${?}" -ne 0 ]]; then
		return 1
	else
		return 0	
	fi
}
disable_user(){
	checking_UID
	sudo chage -E 0 "$USER_NAME"
	if [[ "${?}" -ne 0 ]]; then
		return 1
	else
		return 0	
	fi
}

#Make sure the script is being executed with superuser priv.
if [[ "${UID}" -ne 0 ]]
then
	echo 'Please run with sudo or as root.'  
	exit 1
fi

#Seting up flags for operators 
while getopts dra OPTION
do
	case ${OPTION} in
		d) DELITING='true' ;;
		r) REMOVING='true' ;;
		a) BACKUPING='true' ;;
		?) usage ;;
	esac
done

#removing options from arguments 
shift "$((OPTIND-1))"

#If the user doesn't supply at least one argument , give them help.
if [[ "${#}" -lt 1 ]]
then
	usage	
fi

#Loop trough all the usernames supplied as arguments 

 while [[ $# -gt 0 ]] 
 do
 	USER_NAME="$1"
 	shift
	if [[ "$BACKUPING" == 'true' ]]; then
		backup_user
		
			if [[ "${?}" -eq 0 ]]; then
				echo "User $USER_NAME was backuped in archive folder"
			else
				echo  "Could not create ${ARCHIVE_DIR}/${USER_NAME}.tar.gz" >&2
				exit 1	
			fi	
	fi

	if [[ "$REMOVING" == 'true' ]]; then
		remove_folder

		if [[ "${?}" -eq 0 ]]; then
				echo "User $USER_NAME was deleted and his/her folder"
				
				else	
				echo "User $USER_NAME was unable to delete and his/her folder" >&2
				exit 1	
		fi	

	elif [[ "$DELITING" == 'true' ]]; then
		delete_user	
		if [[ "${?}" -eq 0 ]]; then
				echo "User $USER_NAME was deleted "
				else	
				echo "User $USER_NAME was unable to delete" >&2
				exit 1	
		fi
	

	else 

		disable_user
				if [[ "${?}" -eq 0 ]]; then
				echo "User $USER_NAME was disabled"
				else	
				echo "User $USER_NAME disable failed" >&2
				exit 1	
		fi
	fi

	
 done
 
exit 0