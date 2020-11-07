#!/bin/bash

RETVAL=0

WHOAMI=`whoami`
AWS_DIR="$HOME/.aws/"
ENV=$( ls ${AWS_DIR}credentials-* | cut -d '-' -f2- )
AWS_CONF="credentials"
ACTUAL_AWS_CONF=`readlink $AWS_CONF`

list() {
  for i in ${ENV[@]}; do
    if [[ $ACTUAL_AWS_CONF == *${i}* ]]; then
      echo "$i  [ Currently Selected ]";
    else 
      echo $i;
    fi
  done
}

switch() {
  switch_to="$1"
  if [ "$switch_to" == '' ]; then
    echo "Missing desired account";
    exit 1;
  fi

  for i in ${ENV[@]}; do
    if [[ $ACTUAL_AWS_CONF != *${i}* ]]; then
      cd $AWS_DIR;
      unlink $AWS_CONF 2> /dev/null;
      ln -s ${AWS_CONF}-${switch_to} $AWS_CONF
      continue;
    fi
  done  
}

case "$1" in
  list)
    list
    ;;

  switch)
    switch $2
    ;;
  *)

  echo $"Usage: $0 {list|switch}"
  echo
  list
  exit 1
esac

exit $RETVAL

