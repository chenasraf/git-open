#!/usr/bin/env zsh

open_url() {
  silent=""
  if [[ "$1" =~ "-s|--silent" ]]; then
    silent=1
    shift
  fi
  if [[ "$1" == "" && $# -gt 1 ]]; then
    shift
  fi
  if [[ -z "$silent" ]]; then
    echo "Opening $1"
  fi
  is_mac=$(uname | grep -i darwin)
  is_linux=$(uname | grep -i linux)
  if [[ ! -z $is_mac ]]; then
    open $1
  elif [[ ! -z $is_linux ]]; then
    xdg-open $1
  fi
}

