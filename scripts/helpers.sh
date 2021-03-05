#!/bin/bash

source scripts/colors.sh

# Public: Showing a confirm message
#
# $1 - Message to be shown.
#
# Examples
#
#   confirm "Do you want to delete it?"
#   response=$?
#
# Returns 1 when input is y|yes|Y and 0 when it's n|no|N
confirm() {

  if [ -z "$1" ];then
  echo "Missing message"
  exit
  fi

  read -r -p "$(echo -e $YELLOW$1 "[Y|n]" $NOCOLOR)" response

  # Validate response
  if [[ ! $response =~ (y|yes|Y|n|no|N) ]];then
    confirm "$1"
  fi

  [[ $response =~ (y|yes|Y) ]] && return 1 || return 0
}

# Public: Print out a markup section header
#
# $1 - A section name.
#
# Examples
#
#   section "Templates"
#
section() {
  echo ""
  echo -e "${GREEN}# ----------------------------------"
  echo "# $1"
  echo -e "# ----------------------------------${NOCOLOR}"
}

# Public: Print out a info log
#
# $1 - A log message.
#
# Examples
#
#   info "Coping your files"
#
info() {
  echo "$1"
}

# Public: Print out a success log
#
# $1 - A log message.
#
# Examples
#
#   success "Successfully copied"
#
success() {
  echo -e "${GREEN}$1${NOCOLOR}"
}
