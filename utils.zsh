#!/usr/bin/env zsh

open_url() {
  echo "Opening $1"
  is_mac=$(uname | grep -i darwin)
  is_linux=$(uname | grep -i linux)
  if [[ ! -z $is_mac ]]; then
    open $1
  elif [[ ! -z $is_linux ]]; then
    xdg-open $1
  fi
}

