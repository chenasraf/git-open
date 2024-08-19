#!/usr/bin/env zsh

snap="${0:A:h}/snapshot.txt"
. "${0:A:h}/../git-open.zsh" > $snap
