#!/usr/bin/env python -u
# -*- encoding: utf-8 -*-

import os
import re
import sys
import sqlite3

def get_db():
    db = set()

    book_db = os.path.join(os.path.expanduser("~/Library/Application Support/Books/Books.books-data"))
    con = sqlite3.connect(book_db, isolation_level=None)
    cursor = con.execute("select zisbn from zbook")

    for row in cursor:
        db.add(row[0])

    con.close()
    return db

def insert_isbns(isbns):
    book_db = os.path.join(os.path.expanduser("~/Library/Application Support/Books/Books.books-data"))

    con = sqlite3.connect(book_db, isolation_level=None)
    cursor = con.cursor()
    for isbn in isbns:
        cursor.execute('insert into zbook (z_ent, z_opt, zlist, z5_list, zlistname, ztitle, zisbn) '
                       'values (?, ?, ?, ?, ?, ?, ?)', (1, 4, 2, 5, "eBooks", "Loaded Book", isbn))
        "Z_ENT Z_OPT ZLIST Z5_LIST ZLISTNAME ZISBN      ZID                                  ZTITLE"
        "1     4     2     5       eBooks    8586014133 A84EA61A-597B-416A-92DE-12CE2D01CFAD New Book"

    con.commit()
    con.close()


def main():
    try:
        directory = sys.argv[1]
    except IndexError:
        print >>sys.stderr, "Usage: %s directory" % (sys.argv[0],)
        sys.exit(1)

    if not os.path.isdir(directory):
        print >>sys.stderr, "Usage: %s directory" % (sys.argv[0],)
        sys.exit(1)

    isbn_re = re.compile("^([0-9]{9}[0-9Xx]).pdf")
    db = get_db()

    to_add = set()

    for filename in os.listdir(directory):
        isbn_match = isbn_re.match(filename)
        if not isbn_match:
            continue
        isbn = isbn_match.groups()[0]
        if isbn not in db:
            to_add.add(isbn)

    insert_isbns(to_add)
    print len(to_add), "inserted."

if __name__ == "__main__":
    main()

