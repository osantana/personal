#/bin/bash

action() {
    regex="s/.*\([0-9]\{9,12\}[0-9xX]\).*\.\($1\)$/\1.\2/"
    ls -d -1 * | while read i; do
 	    if echo "$i" | grep "[0-9]\{9,12\}[0-9xX].*$1$" > /dev/null; then
 	        if [ "$2" ]; then
     		    echo mv "$i" _isbn/"$(echo "$i" | sed $regex)"
     		else
     		    mv "$i" _isbn/$(echo "$i" | sed $regex )
     		fi
 	    fi
    done
}

action $1 verify

echo -n Confirma?
read response

if [ "$response" == "y" ]; then
    action $1
fi