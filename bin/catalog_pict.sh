#!/bin/bash

find "$HOME/Pictures/iPhoto Library" | while read fullname; do
    if [ ! -f "$fullname" ]; then
        continue
    fi
    dir=$(dirname "$fullname")
    echo $(md5 -q "$fullname")	$(stat -f "%Sm" -t"%Y%m%d%H%M%S" "$fullname")	$(stat -f "%Sm" -t"%Y%m%d%H%M%S" "$dir")	$fullname
done
