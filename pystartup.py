import sys
import atexit
import os
import rlcompleter

# Enable syntax completion
try:
    import readline
except ImportError:
    print("Module readline not available.")
else:
    import rlcompleter
    readline.parse_and_bind("tab: complete")

sys.path.append(os.path.expanduser("~/.python"))

historyPath = os.path.expanduser("~/.pyhistory")
historyTmp = os.path.expanduser("~/.pyhisttmp.py")
endMarkerStr= "# # # histDUMP # # #"

saveMacro= "import readline; readline.write_history_file('"+historyTmp+"'); \
    print '####>>>>>>>>>>'; print ''.join(filter(lambda lineP: \
    not lineP.strip().endswith('"+endMarkerStr+"'),  \
    open('"+historyTmp+"').readlines())[:])+'####<<<<<<<<<<'"+endMarkerStr

readline.parse_and_bind('tab: complete')
readline.parse_and_bind('\C-w: "'+saveMacro+'"')

def save_history(historyPath=historyPath, endMarkerStr=endMarkerStr):
    import readline
    readline.write_history_file(historyPath)
    # Now filter out those line containing the saveMacro
    lines= filter(lambda lineP, endMarkerStr=endMarkerStr:
                      not lineP.strip().endswith(endMarkerStr), open(historyPath).readlines())
    open(historyPath, 'w+').write(''.join(lines))

try:
    readline.read_history_file(historyPath)
except IOError:
    pass

atexit.register(save_history)

del os, atexit, readline, rlcompleter, save_history, historyPath
del historyTmp, endMarkerStr, saveMacro


