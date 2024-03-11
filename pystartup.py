import sys
import atexit
import os
import readline
import rlcompleter

path = os.path.expanduser("~/.pyhistory")
marker = "### HISTORY DUMP ###"

def save_history(path=path, marker=marker, readline=readline):
    readline.write_history_file(path)
    with open(path) as history:
        lines = [line for line in history if not line.strip().endswith(marker)]
    open(path, "w+").write("".join(lines))

def main():
    sys.path.append(os.path.expanduser("~/.python"))
    readline.parse_and_bind("tab: complete")
    try:
        readline.read_history_file(path)
    except IOError:
        pass


atexit.register(save_history)

del sys, atexit, os, readline, rlcompleter
del save_history, main, path, marker
