#!/bin/bash
#
#this script creates a new use on the local system
# You must supply a username as an argument to the script
#Optionally , you can also provide a comment for the account as an argument.
# A password generetion
# The username, password , and host for the account will be dusplayed

#Make sure the script is being executed with superuser priv.
if [[ "${UID}" -ne 0 ]]
then
	echo 'Please run with sudo or as root.'
	exit 1
fi
if [[ "${#}" -lt 1 ]]
then
	echo "Usage: ${0} USER_NAME [COMMENT].."
	echo 'Create an account on the local system with the name of USER_NAME and comments field of COMMENT.'
	exit 1
fi
#The fisrt command is the user name
USER_NAME="${1}"
#The rest of the parameters are for the account comments.
shift
COMMENT="${@}"
#Generate a password
PASSWORD=$(date +%s%N | sha256sum | head -c48)
#Create the user with the password
useradd -c "${COMMENT}" -m ${USER_NAME} 
#Check to see if the useradd command succeeded
if [[ "${?}" -ne 0 ]]
then
	echo 'The account could not be created'
	exit 1
fi
# Set the password.
echo ${PASSWORD} |	passwd --stdin ${USER_NAME}
if [[ "${?}" -ne 0 ]]
then
	echo 'The password for the account could not be set'
	exit 1
fi
#Force password change on first login 
passwd -e ${USER_NAME}
#Display the username , password , and the host where the user was created
echo
echo 'username:' | echo "${USER_NAME}" 
echo 
echo 'password:' | echo "${PASSWORD}"
echo
echo 'host:' | echo "${HOSTNAME}"
exit 0
#end