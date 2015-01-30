#!/bin/bash

DIRPERM=0755
FILEPERM=0644

if [ "$1" == "--owner" ]; then
    DIRPERM=0700
    FILEPERM=0600
    shift
fi

find "$1" -type d -exec chmod $DIRPERM {} \;
find "$1" -type f -exec chmod $FILEPERM {} \;
