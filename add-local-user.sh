#!/bin/bash
#This script creates an account on the local system
#You will be prompted for the account name and password
USER_UID=${UID}
HOST_MACHINE=$(hostname)
if [[ USER_UID -ne 0 ]]
then
	echo "You need to be a root to execute thi script"
	exit 1
fi		
read -p 'Enter the username to create: ' USER_NAME
read -p 'Enter the name of the person who this account id for:' COMMENT
read -p 'Enter the password to use for the account:' PASSWORD
useradd -c "${COMMENT}" -m ${USER_NAME} 
echo ${PASSWORD}| passwd --stdin ${USER_NAME}
if [[ ${?} -ne 0 ]]
then
	echo "Can't create user"
	exit 1
fi	
passwd -e ${USER_NAME}
echo " ${COMMENT} user name is : ${USER_NAME}  pasword: ${PASSWORD} . Host ${HOST_MACHINE} "







