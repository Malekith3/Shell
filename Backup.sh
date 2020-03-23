#!/bin/bash
#Simple script for backup file and log it .
#This function sends a message to syslog and to standart output if VERBOSE is true.
log() {
	local MESSAGE="${@}"
	if [[ "${VERBOSE}" = 'true' ]]
	 then
		echo "${MESSAGE}"
	fi	
	logger -t luser-demo10.sh "${MESSAGE}"
}


backup_file(){
	#This function creates a backup of a file. Returns non-zero status on error
	local FILE="${1}"

	if [[ -f "${FILE}" ]]
	then
		local BACKUP_FILE="/var/tmp/$(basename ${FILE}).$(date +%F-%N)"
		log "Backing up ${FILE} to ${BACKUP_FILE}."
		cp -p ${FILE} ${BACKUP_FILE}
	else
		return 1
	fi


}

readonly VERBOSE='true'
backup_file '/etc/passwd'
