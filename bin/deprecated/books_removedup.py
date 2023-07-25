import sys
import sqlite3

con = sqlite3.connect(sys.argv[1], isolation_level=None)

cursor = con.execute("select zisbn from zbook")

for row in cursor:
    isbn = row[0]

    dup = con.execute("select z_pk, zisbn from zbook where zisbn = '%s'" % (isbn,))
    res = list(dup)

    if len(res) > 1:
        print "Removing:", isbn
        d = con.execute("delete from zbook where z_pk = %s" % (res[0][0],))

con.close()
