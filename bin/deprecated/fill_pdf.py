#!/usr/bin/env python -u
# -*- encoding: utf-8 -*-

import os
import re
import sys
import sqlite3
import anydbm

from amazon import get as get_amazon

def get_db():
    db = {}

    book_db = os.path.join(os.path.expanduser("~/Library/Application Support/Book_Hunter/Book-Hunter-Library.sql"))
    con = sqlite3.connect(book_db, isolation_level=None)
    cursor = con.execute("select zisbn, ztitle, zauthor from zbook")

    for row in cursor:
        isbn, title, authors = row
        if not title or not authors:
            continue
        try:
            sanitized_authors = ", ".join(authors.strip("""'",""").split(";"))
        except AttributeError:
            sanitized_authors = ""
        db[isbn] = {
            'isbn': isbn,
            'title': title.strip("""'","""),
            'author': sanitized_authors,
        }
        for k in db[isbn]:
            if db[isbn][k] is None:
                db[isbn][k] = ""
            db[isbn][k] = db[isbn][k].encode('utf-8')
    con.close()

    return db

def main():
    try:
        status_file = sys.argv[1]
        to_convert = sys.argv[2:]
    except IndexError:
        print >>sys.stderr, "Usage: %s status_file list_of_pdf_files" % (sys.argv[0],)

    isbn_re = re.compile("^([0-9]{9}[0-9Xx]).pdf")
    converted = 0
    total = len(to_convert)

    done = anydbm.open(status_file, "c")

    for i, filename in enumerate(to_convert):
        isbn_match = isbn_re.match(filename)
        if not isbn_match:
            continue

        isbn = isbn_match.groups()[0]
        if isbn in done and done[isbn] == "OK":
            print "%4d/%4d (%6.2f%%)  Skipping: %s (%s)" % (i, total, (float(i)/total)*100, isbn, done[isbn])
            continue

        res = get_amazon(isbn)
        if res:
            try:
                book_data = {
                    'title': res[0]['Title'].replace("'", r"\'"),
                    'author': res[0]['Author'].replace("'", r"\'"),
                    'isbn': isbn,
                }
            except KeyError:
                continue

        print "%4d/%4d (%6.2f%%)  Updating: %s" % (i, total, (float(i)/total)*100, isbn),
        cmd = "pdfauxinfo -i %(isbn)s.pdf -o %(isbn)s.updated.pdf -a \"%(author)s\" -t \"%(title)s\"" % book_data
        try:
            res = os.system(cmd)
        except (UnicodeEncodeError, UnicodeDecodeError, OSError, IOError), ex:
            done[isbn] = "ERROR"
            done.sync()
            continue

        if res:
            done[isbn] = "ERROR"
            done.sync()
            continue
        else:
            print

        try:
            os.remove("%s.pdf" % (isbn,))
            os.rename("%s.updated.pdf" % (isbn,), "%s.pdf" % (isbn,))
        except OSError:
            continue

        done[isbn] = "OK"
        done.sync()
        converted += 1

    done.close()
    print "%s conversion(s), %s error(s) of %s file(s)" % (converted, len(to_convert) - converted, len(to_convert))

if __name__ == "__main__":
    main()

