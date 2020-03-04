#!/usr/bin/env python

import os
import sys
import shutil
import hashlib


def md5(filename):
    with open(filename, "rb") as input_file:
        return hashlib.md5(input_file.read()).digest()


def equals(src, dst):
    return md5(src) == md5(dst)


def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} source target")
        sys.exit(1)

    source = os.path.realpath(sys.argv[1])
    target = os.path.realpath(sys.argv[2])

    for path, _, files in os.walk(source):
        relativesrc = path.replace(source, "")[1:]

        for filename in files:
            sourcefile = os.path.join(source, relativesrc, filename)
            targetpath = os.path.join(target, relativesrc)
            targetfile = os.path.join(targetpath, filename)

            print(sourcefile, "=>", targetfile, end=" ")

            if not os.path.exists(targetfile):
                os.makedirs(os.path.dirname(targetfile), exist_ok=True)

                shutil.copy(sourcefile, targetfile)
                print("copied.", end=" ")

                os.remove(sourcefile)
                print("removed source.")
                continue

            if not equals(sourcefile, targetfile):
                shutil.copy(sourcefile, targetfile + ".2")
                print("conflict.", end=" ")

                os.remove(sourcefile)
                print("removed source.")
                continue

            os.remove(sourcefile)
            print("skipped. removed source.")


if __name__ == "__main__":
    main()
