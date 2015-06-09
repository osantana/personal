#!/usr/bin/env python
# -*- encoding: utf-8 -*-
#
# isbn.py
#
# Code for messing with ISBN numbers
# Especially stuff for converting between ISBN-10 and ISBN-13
#
# Copyright (C) 2007 Darren J Wilkinson
#               2008 Osvaldo Santana Neto <osantana@gmail.com>
#
# Free GPL code
# Last updated: 14/8/2007

"""
Code for messing with ISBN numbers. Stuff for validating ISBN-10 and
ISBN-13 numbers, computing check digits and converting from one format
to the other.

This code doesn't know anything about proper hyphenation of ISBNs. Nor does
it know anything about the real "validity" of ISBNs - it just validates on
the basis of the check-digit.

Some examples::

    >>> valid("3-79081-945-X")
    True
    >>> valid("1-58488-540-8")
    True
    >>> valid("1-58488-540-5")
    False
    >>> valid("978-1@#$5848ZZZYYY8-540-5")
    True
    >>> check("1-58488-540")
    '8'
    >>> check("3-79081-945")
    'X'
    >>> check("978-158488-540")
    '5'
    >>> valid_isbn13("978-158488-540-5")
    True
    >>> valid_isbn10("978-158488-540-5")
    False
    >>> strip("978-1ZYUI58488-540-5")
    '9781584885405'
    >>> convert("1-58488-540-8")
    '9781584885405'
    >>> convert("978-158488-540-5")
    '1584885408'
    >>> convert("1-8758488-540-8")
    Traceback (most recent call last):
        ...
    ValueError: Invalid ISBN
    >>> to_isbn13("1-58488-540-8")
    '9781584885405'
    >>> to_isbn13("978-158488-540-5")
    '9781584885405'
    >>> to_isbn10("978-158488-540-5")
    '1584885408'
    >>> to_isbn10("1584885408")
    '1584885408'
    >>> format("1584885408", "")
    '1584885408'
    >>> format("1584885408", "-")
    '1-58488-540-8'
    >>> format("1584885408", " ")
    '1 58488 540 8'
    >>> format("9781584885405")
    '9781584885405'
    >>> format("9781584885405", "-")
    '978-158488-540-5'
    >>> format("97815ASDQWE!@#84885405", "-")
    '978-158488-540-5'
    >>> format("9781584883ASDF@#$l5405", "-")
    '9781584883ASDF@#$l5405'
    >>> url("amazon", "978-158488-540-5")
    'http://www.amazon.com/o/ASIN/1584885408'

The code is very simple pure python code in a single source file. Please
read the source code file (isbn.py) for further information about how
it works.

Please send bug reports, bug fixes, etc. to:
darrenjwilkinson@btinternet.com
Free GPL code, Copyright (C) 2007 Darren J Wilkinson
http://www.staff.ncl.ac.uk/d.j.wilkinson/

Or, if you are using the isbn.py utility version send your bug reports, fixes,
etc. to:
Osvaldo Santana Neto <osantana@gmail.com>
http://www.pythonologia.org/
"""

import sys

(OK,
 INVALID,
 ERROR,
) = range(3)

def strip(isbn):
    """Strip whitespace, hyphens, etc. from an ISBN number and return the result."""
    return filter(lambda x: str.isdigit(x) or x.upper() == "X", isbn)

def convert(isbn):
    """Convert an ISBN-10 to ISBN-13 or vice-versa."""

    short = strip(isbn)
    if not valid(short):
        raise ValueError("Invalid ISBN")

    if len(short) == 10:
        stem = "978" + short[:-1]
        return stem + check(stem)
    else:
        if short.startswith("978"):
            stem = short[3:-1]
            return stem + check(stem)
        else:
            raise ValueError("ISBN not convertible")

def valid(isbn):
    """Check the validity of an ISBN. Works for either ISBN-10 or ISBN-13."""

    short = strip(isbn)
    if len(short) == 10:
        return valid_isbn10(short)
    if len(short) == 13:
        return valid_isbn13(short)
    return False

def check(stem):
    """Compute the check digit for the stem of an ISBN. Works with either the
    first 9 digits of an ISBN-10 or the first 12 digits of an ISBN-13."""

    short = strip(stem)
    if len(short) == 9:
        return check_isbn10(short)
    if len(short) == 12:
        return check_isbn13(short)
    return False

def check_isbn10(stem):
    """Computes the ISBN-10 check digit based on the first 9 digits of a
    stripped ISBN-10 number."""

    check = 11 - sum( (x+2) * int(y) for x,y in enumerate(reversed(stem)) ) % 11
    if check == 10:
        return "X"
    elif check == 11:
        return "0"

    return str(check)

def valid_isbn10(isbn):
    """Checks the validity of an ISBN-10 number."""

    short = strip(isbn)
    if len(short) != 10:
        return False

    digits = [ (10 if x.upper() == "X" else int(x)) for x in short ]
    return (sum( (x+1)*y for x,y in enumerate(reversed(digits)) ) % 11) == 0

def check_isbn13(stem):
    """Compute the ISBN-13 check digit based on the first 12 digits of a
    stripped ISBN-13 number. """

    check = 10 - sum( (x%2*2+1) * int(y) for x,y in enumerate(stem) ) % 10
    if check == 10:
        return "0"

    return str(check)

def valid_isbn13(isbn):
    """Checks the validity of an ISBN-13 number."""

    short = strip(isbn)
    if len(short) != 13:
        return False

    digits = [ (10 if x.upper() == "X" else int(x)) for x in short ]
    return (sum( (x%2*2+1) * y for x,y in enumerate(digits) ) % 10) == 0

def to_isbn10(isbn):
    """Converts supplied ISBN (either ISBN-10 or ISBN-13) to a stripped ISBN-10."""

    if not valid(isbn):
        raise ValueError("Invalid ISBN")

    if valid_isbn10(isbn):
        return strip(isbn)
    else:
        return convert(isbn)

def to_isbn13(isbn):
    """Converts supplied ISBN (either ISBN-10 or ISBN-13) to a stripped ISBN-13."""

    if not valid(isbn):
        raise ValueError("Invalid ISBN")

    if valid_isbn13(isbn):
        return strip(isbn)
    else:
        return convert(isbn)

def url(type_, isbn):
    """Returns a URL for a book, corresponding to the "type" and the "isbn"
    provided. This function is likely to go out-of-date quickly, and is
    provided mainly as an example of a potential use-case for the module.
    Currently allowed types are "google-books" (the default if the type is not
    recognised), "amazon", "amazon-uk", "blackwells"."""

    short = to_isbn10(isbn)

    providers = {
        'amazon':     'http://www.amazon.com/o/ASIN/%s',
        'amazon-uk':  'http://www.amazon.co.uk/o/ASIN/%s',
        'blackwells': 'http://bookshop.blackwell.co.uk/jsp/welcome.jsp?action=search&type=isbn&term=%s',
    }

    return providers.get(type_, "http://books.google.com/books?vid=%s") % (short,)

def format(isbn, sep=""):
    s = strip(isbn)

    if len(s) == 10:
        return s[0] + sep + s[1:6] + sep + s[6:9] + sep + s[9]

    if len(s) == 13:
        return s[0:3] + sep + s[3:9] + sep + s[9:12] + sep + s[12]

    return isbn

def main():
    from optparse import OptionParser

    usage = """usage: %prog [options] ISBN

    If ISBN arg is an ISBN-13:
        --isbn13 will check the ISBN number (and return an error code with the result)
        --isbn10 will convert the ISBN-13 to ISBN-10

    If ISBN arg is an ISBN-10:
        --isbn10 will check the ISBN number (and return an error code with the result)
        --isbn13 will convert the ISBN-10 to ISBN-13
    """

    parser = OptionParser(usage=usage)
    parser.add_option("-3", "--isbn13", action="store_true", dest="isbn13", default=True,
        help="check or convert a ISBN-13 value (default)")
    parser.add_option("-0", "--isbn10", action="store_false", dest="isbn13",
        help="check or convert a ISBN-10 value")
    parser.add_option("-s", "--separator", dest="separator", metavar="SEP", default="",
        help="select a ISBN separator character. (default: '%default')")
    parser.add_option("-q", "--quiet", action="store_false", dest="verbose", default=True,
        help="quiet (no output)")
    parser.add_option("-t", "--test", action="store_true", dest="test",
        help="test internal functions (useful for developers).")

    (options, args) = parser.parse_args()

    if options.test:
        import doctest
        doctest.testmod()
        sys.exit(0)

    if not args:
        parser.error("incorrect number of arguments.")

    verbose = options.verbose
    separator = options.separator
    isbn = strip(args[0])

    if len(isbn) == 13:
        valid_func = valid_isbn13
        only_check = options.isbn13
    elif len(isbn) == 10:
        valid_func = valid_isbn10
        only_check = not options.isbn13
    else: # invalid input
        if verbose:
            print "INVALID: %s" % (isbn,)
        return INVALID


    if only_check:         # check it
        if valid_func(isbn): # OK!
            if verbose:
                print format(isbn, separator)
            return OK
        else:                  # NOT OK!
            if verbose:
                print "INVALID: %s" % (isbn,)
            return INVALID
    else:                      # convert it
        try:
            n_isbn = convert(isbn)
        except ValueError:     # CANNOT CONVERT!
            if verbose:
                print "INVALID: %s" % (isbn,)
            return INVALID
        if verbose:            # CONVERT!
            print format(n_isbn, separator)
        return OK


if __name__=='__main__':
    sys.exit(main())

# vim:ts=4:sw=4:et:si:ai:sm
