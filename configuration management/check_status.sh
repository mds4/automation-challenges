#!/bin/bash
# check the status of all defined vagrant virtual machines to determine if the widgetfile was correctly templated

# vagrant binary
VAGRANT=`which vagrant`

# template file
TEMPLATE_FILE="/etc/widgetfile"

# templated line to look for
TEMPLATE_LINE="widget_type"



# make sure Vagrant is installed
if [[ ! -x ${VAGRANT} ]]; then
  echo -e "\033[31;1mVagrant doesn't appear to be installed or isn't executable.\033[0m\nYou can install it from https://www.vagrantup.com/downloads.html"
  exit 1
fi

# use the global .vagrant directory to store box info, instead of in this directory
export VAGRANT_DOTFILE_PATH=~/.vagrant/

# pull status information to find all of the boxes and their status
statuses=`${VAGRANT} status | grep virtualbox`
boxes=`echo "${statuses}" | awk '{print \$1}'`

success=0
fail=0
down=0

# run through each box and determine its status, and if it's up, check the template status
for box in ${boxes}; do
  status=`echo "${statuses}" | grep ${box} | sed -e 's/ \{1,\}/ /g'` # get the box status and munge multiple spaces into one
  status=${status#* } # remove the first field (name)
  status=${status% *} # remove the last field (provider)
  if [[ "${status}" == "running" ]]; then
    # checks to make sure widgetfile exists and widget_type is in the file
    widgettype=`${VAGRANT} ssh ${box} -c "grep ${TEMPLATE_LINE} ${TEMPLATE_FILE}" 2>/dev/null`
    RC=$?
    widgettype=`echo ${widgettype} | tr -d '\r'` # 'vagrant ssh' adds \r\n to command output, so remove the \r
    if [[ ${RC} -ne 0 ]]; then
      fail=$((${fail}+1))
      if [[ ${RC} -eq 1 ]]; then
        echo -e " - \033[31;1m${box}\033[0m did not have \033[1m${TEMPLATE_LINE}\033[0m in \033[1m${TEMPLATE_FILE}\033[0m"
      elif [[ ${RC} -eq 2 ]]; then
        echo -e " - \033[31;1m${box}\033[0m did not have \033[1m${TEMPLATE_FILE}\033[0m"
      fi
    else
      # checks to make sure widget_type is defined as something
      widgettype=`echo ${widgettype} | cut -s -d\  -f 2-`
      if [[ -z "${widgettype}" ]]; then
        fail=$((${fail}+1))
        echo -e " - \033[31;1m${box}\033[0m did not have a value for \033[1m${TEMPLATE_LINE}\033[0m"
      else
        success=$((${success}+1))
        echo -e " - \033[32;1m${box}\033[0m: \033[1m${TEMPLATE_LINE}\033[0m is '\033[1m${widgettype}\033[0m'\033[0m"
      fi
    fi
  else
    down=$((${down}+1))
    echo -e " - \033[33;1m${box}\033[0m is \033[1mdown\033[0m"
  fi
done

echo ""
printf "\033[32m%-12.12s %4d\033[0m\n" "Successful:" ${success}
printf "\033[31m%-12.12s %4d\033[0m\n" "Failure:" ${fail}
printf "\033[33m%-12.12s %4d\033[0m\n" "Down:" ${down}
echo ""
