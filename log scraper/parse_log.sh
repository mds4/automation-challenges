#!/bin/bash

# File to operate on
FILE="puppet_access_ssl.log"

# count the number of times /production/file_metadata/modules/ssh/sshd_config was fetched
SSHD_CONFIG_FETCHED=`awk 'BEGIN {COUNT=0} $7 ~ /^\/production\/file_metadata\/modules\/ssh\/sshd_config/{COUNT++} END{print COUNT}' $FILE`\

# count the number of times /production/file_metadata/modules/ssh/sshd_config was fetched with a non-200 result
SSHD_CONFIG_NON_200=`awk 'BEGIN {COUNT=0} $7 ~ /^\/production\/file_metadata\/modules\/ssh\/sshd_config/ && $9 != "200"{COUNT++} END{print COUNT}' $FILE`

# count the number of non-200 results
TOTAL_NON_200=`awk 'BEGIN {COUNT=0} $9 != "200"{COUNT++} END{print COUNT}' $FILE`

# count the number of PUT requests to /dev/report/...
PUT_DEV_REPORT=`awk 'BEGIN {COUNT=0} $6 ~ /PUT$/ && $7 ~ /^\/dev\/report\//{COUNT++} END{print COUNT}' $FILE`

# count the number of PUT requests to /dev/report/... by IP address (sorted by count then address)
PUT_DEV_REPORT_IPS=`awk '$6 ~ /PUT$/ && $7 ~ /^\/dev\/report\//{print $1}' $FILE | sort | uniq -c | sort -n -t. -k 1,1 -k 2,2 -k 3,3 -k 4,4`


# Output
echo -e "/production/file_metadata/modules/ssh/sshd_config was fetched \033[1m${SSHD_CONFIG_FETCHED}\033[0m times, with \033[1m${SSHD_CONFIG_NON_200}\033[0m non-200 return codes."
echo -e "There were a total of \033[1m${TOTAL_NON_200}\033[0m non-200 return codes."
echo -e "There were \033[1m${PUT_DEV_REPORT}\033[0m PUT requests to paths under /dev/report/, with the following distribution:\n${PUT_DEV_REPORT_IPS}"
echo ""
