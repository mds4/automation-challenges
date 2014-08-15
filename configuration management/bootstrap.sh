#!/bin/bash

# bootstraps the virtual machines for this assignment

VAGRANT=`which vagrant`
VIRTUALBOX=`which virtualbox`

# make sure Vagrant is installed
if [[ ! -x ${VAGRANT} ]]; then
  echo -e "\033[31;1mVagrant doesn't appear to be installed or isn't executable.\033[0m\nYou can install it from https://www.vagrantup.com/downloads.html"
  exit 1
fi

# make sure Virtualbox is installed
if [[ ! -x ${VIRTUALBOX} ]]; then
  echo -e "\033[31;1mVirtualbox doesn't appear to be installed or isn't executable.\033[0m\nYou can install it from https://www.virtualbox.org/wiki/Downloads"
  exit 1
fi

echo -e "\033[32;1mYour setup looks good, let's get started here...\033[0m"

# use the global .vagrant directory to store box info, instead of in this directory
export VAGRANT_DOTFILE_PATH=~/.vagrant/

# run 'vagrant up' to bring up the first three boxes and the last one
echo -e "\033[32;1mBringing up boxes 01, 02, 03, and 05...\033[0m\n"
${VAGRANT} up

# Run the report
echo -e "\n\033[32;1mRunning the status report...\033[0m\n"
./check_status.sh

# Now bring up the 4th box
echo -e "\n\033[32;1mBringing up box 04...\033[0m\n"
${VAGRANT} up box04

# Run the report again
echo -e "\n\033[32;1mRunning the status report again...\033[0m\n"
./check_status.sh

# get rid of all 5 boxes
echo -e "\n\033[32;1mDestroying all five boxes...\033[0m\n"
${VAGRANT} destroy -f
echo -e "\n\033[32;1mAll done!\033[0m"
