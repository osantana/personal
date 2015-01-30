#!/bin/bash

find $1 -type f -name "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9xX].pdf" | while read filename; do
    if grep "$filename" find_no_metadata.data > /dev/null; then
        continue
    fi
    echo -n "=== File: $(basename $filename) => "
    output="$(pdftk $filename dump_data 2> /dev/null | grep -A1 '\(InfoKey: Title\|InfoKey: Author\)' | grep -v -f ~/bin/find_no_metadata_exclusion.txt)"
    count=$(echo -n "$output" | wc -l | sed 's/^ *//')
    if [ "$count" != "4" ]; then
        echo "Add metadata ($count)"
        echo "$filename" >> $2
    else
        echo "Metadata Ok ($count)"
        echo "$output" | sed "s/^/    /"
    fi
    echo $filename >> find_no_metadata.data
done
[ -f find_no_metadata.data ] && rm -f find_no_metadata.data
