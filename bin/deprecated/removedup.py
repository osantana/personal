#!/usr/bin/env python

import os
import sys
import hashlib

from optparse import OptionParser


def walk_files(*paths):
    for path in paths:
        for root, dirs, files in os.walk(path):
            for filename in files:
                yield os.path.join(root, filename)

class File(object):

    def __init__(self, path):
        self.path = os.path.realpath(path)
        self._md5 = None

    @property
    def md5(self):
        if not self._md5:
            md5 = hashlib.md5()
            fileobj = open(self.path)
            md5.update(fileobj.read())
            fileobj.close()
            self._md5 = md5.hexdigest()
        return self._md5

    def __repr__(self):
        return "%s -> %s" % (self.md5, self.path)

def main():
    db = {}

    parser = OptionParser()
    (options, args) = parser.parse_args()

    for filename in walk_files(*args):
        if filename.endswith(".removed"):
            continue

        fileobj = File(filename)

        if fileobj.md5 not in db:
            db[fileobj.md5] = fileobj
            print fileobj, "added."
            continue

        previous = db[fileobj.md5]

        print
        print "1.", previous
        print "2.", fileobj

        if 'originals' in fileobj.path:
            remove = fileobj
        elif 'originals' in previous.path:
            remove = previous
        else:
            try:
                choose = int(raw_input("Choose one option (enter skip/0 end): "))
            except ValueError:
                continue

            if choose == 0:
                break

            elif choose == 1:
                remove = fileobj
            else:
                remove = previous

        # TODO: put a '--bak' option
        os.rename(remove.path, remove.path + ".removed")
        #os.remove(remove.path)

        print remove, "removed."
        print

        

if __name__ == "__main__":
    main()
