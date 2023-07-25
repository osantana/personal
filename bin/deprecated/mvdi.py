#!/usr/bin/env python

# https://web.ivy.net/~carton/rant/virtualbox-macos-hdiutil.html


import os
import sys
import struct
import subprocess


VDI_DISK_START_POS = 0x158
VDI_SECTOR_SIZE    = 0x200


def main(filename):
    with open(filename) as image:
        image.seek(VDI_DISK_START_POS)
        disk_start = struct.unpack("<I", image.read(4))

    start_sector = disk_start[0] / VDI_SECTOR_SIZE

    subprocess.Popen("ln -sf '%s' '%s.img'" % (filename, filename), shell=True)
    subprocess.Popen("hdid -section %s '%s.img'" % (start_sector, filename), shell=True)

if __name__ == "__main__":
    main(sys.argv[1])
