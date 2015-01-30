#!/bin/sh

# PATHS
PATH_OPENDKIM="/etc/opendkim"
PATH_KEY_TABLE="/etc/opendkim/KeyTable"
PATH_SIGNING_TABLE="/etc/opendkim/SigningTable"
PATH_KEYS="/etc/opendkim/keys"
PATH_BACKUP="/var/backups/opendkim"

# PRIVATE KEYS RIGHTS
PRIVATE_KEYS_USER="opendkim"
PRIVATE_KEYS_GROUP="opendkim"

# ARGUMENTS
KEY_NAME=$1
DOMAIN=$2

# BACKUP
BACKUP_TIME=$(date +%s)
mkdir ${PATH_BACKUP}/${BACKUP_TIME}
cp -R ${PATH_OPENDKIM} ${PATH_BACKUP}/${BACKUP_TIME}

# ADD TO KEY TABLE AND SIGNING TABLE IF NOT EXISTS
STRING_KEY_TABLE="${KEY_NAME}._domainkey.${DOMAIN} ${DOMAIN}:${KEY_NAME}:${PATH_KEYS}/${DOMAIN}/${KEY_NAME}.private"
STRING_SIGNING_TABLE="*@${DOMAIN} ${KEY_NAME}._domainkey.${DOMAIN}"

if grep -Fxq "${STRING_KEY_TABLE}" ${PATH_KEY_TABLE}
then
    echo "Keys already created."
else
    echo ${STRING_KEY_TABLE} >> ${PATH_KEY_TABLE}
    echo ${STRING_SIGNING_TABLE} >> ${PATH_SIGNING_TABLE}

    # CREATE KEYS
    mkdir ${PATH_KEYS}/${DOMAIN}
    cd ${PATH_KEYS}/${DOMAIN}
    opendkim-genkey -s ${KEY_NAME} -d ${DOMAIN}
    chown ${PRIVATE_KEYS_USER}:${PRIVATE_KEYS_GROUP} ${KEY_NAME}.private

    # RESULT
    cat ${KEY_NAME}.txt
fi