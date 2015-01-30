#!/bin/bash

find $1 -type d -exec chmod 0775 {} \;
find $1 -type f -exec chmod 0664 {} \;
find $1 -type d -exec setfacl -m u:apache:rwx {} \;
find $1 -type f -exec setfacl -m u:apache:rw {} \;
find $1 -type d -exec setfacl -m u:osantana:rwx {} \;
find $1 -type f -exec setfacl -m u:osantana:rw {} \;
