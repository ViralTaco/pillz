#!/usr/bin/env bash

# Make sure this file has chmod +x before running.
if [ $USER != 'root' ]; then 
  echo 'Insufficient priviledges to run the install script.'
else

  # TODO: Compilation script.

  rm /usr/local/bin/pillz
  cp ./Build/Products/Release/pillz /usr/local/bin/pillz
  
  if [ $? -eq 0 ]; then
    echo 'Application installed. You can run it by typing pillz'
  else
    echo 'Could not complete installation. Makes sure to run as root.'
  fi
  
  exit $?
fi