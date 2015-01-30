#!/usr/bin/env python

import sys
import os
import glob
import re
import urllib
import time

from xml.etree import ElementTree as ET
from boto.connection import AWSQueryConnection

sys.path.append(os.path.expanduser("~/.passwords"))
from aws import *

def get(keywords):
    aws_conn = AWSQueryConnection(
        aws_access_key_id=ACCESS_KEY_ID,
        aws_secret_access_key=SECRET_ACCESS_KEY,
        is_secure=False,
        host="ecs.amazonaws.com")
    aws_conn.SignatureVersion = "2"

    params = dict(
        Service='AWSECommerceService',
        Version='2008-08-19',
        SignatureVersion=aws_conn.SignatureVersion,
        AWSAccessKeyId=ACCESS_KEY_ID,
        AssociateTag=ASSOCIATE_TAG,
        Operation="ItemSearch",
        SearchIndex="All",
        Keywords=keywords,
        ResponseGroup="ItemAttributes",
        Timestamp=time.strftime("%Y-%m-%dT%H:%M:%S", time.gmtime()),
    )

    verb = 'GET'
    path = "/onca/xml"
    qs, signature = aws_conn.get_signature(params, verb, path)
    qs = path + '?' + qs + '&Signature=' + urllib.quote(signature)
    response = aws_conn._mexe(verb, qs, None, headers={})
    content = response.read()

    tree = ET.fromstring(content)
    NS = tree.tag.split("}")[0][1:]

    res = []
    for item in tree.find('{%s}Items' % NS).findall('{%s}Item' % NS):
        item_dic = {}
        attrs = item.find('{%s}ItemAttributes' % NS)
        if attrs is not None:
            isbn = attrs.find('{%s}ISBN' % NS)
            if isbn is not None:
                item_dic['ISBN'] = isbn.text

            title = attrs.find('{%s}Title' % NS)
            if title is not None:
                item_dic['Title'] = title.text

            author = attrs.find('{%s}Author' % NS)
            if author is not None:
                item_dic['Author'] = author.text


            if 'ISBN' in item_dic and 'Title' in item_dic:
                res.append(item_dic)
    return res


def filtername(name):
    name = name.lower().replace("_", " ").replace(".", " ").replace(" - ", " ").replace("-", " ").strip()
    filters = {
        'apress': '',
        'addison wesley': '',
        'bookman': '',
        'elsevier': '',
        'cambridge': '',
        'prentice hall': '',
        'waite group': '',
        'sams': '',
        'springer': '',
        'sybex': '',
        'syngress': '',
        'linux journal': '',
        'o\'?reilly': '',
        'packt': '',
        'packtpub': '',
        'premier': '',
        r'\b[^a]press\b': '',
        'peachpit': '',
        'new riders': '',
        'morgan kauff?mann?': '',
        'mcgraw[- ]hill': '',
        'microsoft': '',
        'wrox': '',
        'thomson': '',
        'site ?point': '',
        'makron books': '',
        'makron': '',
        'wiley( publishing)?': '',
        'mit': '',
        'wordware': '',
        r'\bebooks?\b': '',
        'ddu': '',
        '^xxx': '',
        '^ddd': '',
        '^ebook': '',
        '\(.*\)': '',
        '\[.*\]': '',
        '  *': ' ',
        '[0-9](st|nd|rd|th)? ed(\.|ition)?': '',
        '[12][09][0-9][0-9]': '',
        ', ?': '',
        '(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[- ]': '',
        '(fev|abr|mai|ago|set|out|dez)': '',
        'tanenbaum': '',
        'taschen': '',
        'tarek ziade': '',
        'flynn': '',
        'forrest mims': '',
        'friends ?of ?ed': '',
        'manning': '',
    }

    for f, r in filters.items():
        name = re.sub(f, r, name)

    return name


def main():
    try:
        d = sys.argv[1]
    except IndexError, ex:
        print >>sys.stderr, "Informe o diretorio"
        sys.exit(1)

    if not os.path.exists('_done'):
        os.mkdir('_done')
    if not os.path.exists('_todo'):
        os.mkdir('_todo')

    for ext in [ '.pdf', '.chm', '.doc', '.djvu', '' ]:
        for fname in glob.glob("%s/*%s" % (d, ext)):
            if fname.startswith('./_') or re.search("[0-9X]{10}", fname):
                continue

            new_name = None
            name = os.path.splitext(os.path.basename(fname))[0]
            name = filtername(name)
            first_name = '"' + filtername(name) + '"'
            print
            print
            print "Searching:", first_name

            try:
                results = get(first_name)
                valids = [ r for r in results if not re.search(r'[^0-9X]', r['ISBN']) ]
                if not valids:
                    print "   No valid ISBN found."
                    continue

                if len(valids) > 40:
                    print "   Skipping..."
                    continue

                if len(valids) > 1:
                    for i, r in enumerate(valids):
                        print u"   %s. %s - %s" % (i + 1, r['Title'], r['ISBN'])
                    print u"->%s" % (fname,)

                    while True:
                        try:
                            c = raw_input("   Escolha (0 continua/o=open/t=todo): ")
                            c = int(c)
                        except ValueError:
                            if c.startswith("o"):
                                os.system("open '%s'" % (fname,))
                                continue
                            elif c.startswith("t"):
                                new_name = "_todo/%s" % (fname,)
                                break
                            else:
                                new_name = None
                                break

                        isbn = valids[int(c) - 1]['ISBN']
                        new_name = "_done/%s/%s%s" % (os.path.dirname(fname), isbn, ext)
                        break

                if not new_name:
                    continue

                try:
                    os.rename(fname, new_name)
                except OSError, ex:
                    print "RENAME ERROR:", fname

                print "Renaming: %s -> %s" % (fname, new_name)

            except KeyError, ex:
                try:
                    os.rename(fname, "_todo/" + fname)
                except OSError, ex:
                    print "RENAME ERROR:", fname
                print "   Not found. (keyerror: %s)" % (ex,)
            except UnicodeEncodeError:
                pass
            except UnicodeDecodeError:
                pass

if __name__ == "__main__":
    main()
