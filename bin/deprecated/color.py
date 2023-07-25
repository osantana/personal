#!/usr/bin/env python

import os
import sys

def go():
    if len(sys.argv) != 2:
        print("Usage: %s <filename>" % sys.argv[0])
        sys.exit(1)
    output_fn, ext = os.path.splitext(sys.argv[1])
    output_fn += '.html'
    print("Generating %s" % (output_fn))
    os.system("pygmentize -O full -o %s %s" % (output_fn, sys.argv[1]))
    print("Copying to clipboard...")
    fullpath = os.path.abspath(output_fn)
    os.system("""osascript<<END
tell application "Safari"
        activate
        make new document at end of documents
        set url of document 1 to "file://%s"
end tell

tell application "System Events"
        tell process "Safari"
                click menu item "Select All" of menu "Edit" of menu bar 1
                click menu item "Copy" of menu "Edit" of menu bar 1
                click menu item "Close Window" of menu "File" of menu bar 1
        end tell
end tell
END
""" % (fullpath))

if __name__ == "__main__":
    go()
