#!/usr/bin/env zsh

snap="${0:A:h}/snapshot.txt"
echo "Updating snapshot $snap"
. "${0:A:h}/../git-open.zsh" > $snap
echo "Snapshot updated"
