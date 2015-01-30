#!/usr/bin/env python

import sys
import csv
import smtplib
import time

from getpass import getpass
from optparse import OptionParser
from email.mime.text import MIMEText

class Gmail(object):
    def __init__(self, username, password, smtp_server, smtp_port):
        self.username = username
        self.password = password
        self.smtp_server = smtp_server
        self.smtp_port = smtp_port
        self.debug_level = 0
        self.server = None

    def connect(self):
        self.server = smtplib.SMTP(self.smtp_server, self.smtp_port)
        self.server.set_debuglevel(self.debug_level)
        self.server.ehlo()
        self.server.starttls()
        self.server.ehlo()
        self.server.login(self.username, self.password)

    def send(self, sender, recipient, subject, message):
        msg = MIMEText(message, _charset="utf-8")
        msg['Subject'] = subject
        msg['From'] = sender
        msg['Reply-To'] = sender
        msg['To'] = recipient

        self.server.sendmail(sender, recipient, msg.as_string())

    def disconnect(self):
        self.server.close()

if __name__ == "__main__":
    usage = """usage: %prog -u USER [options] template database"""
    version = "0.1"

    parser = OptionParser(usage=usage, version=version)

    parser.add_option(
        "-u", "--username", dest="username",
        help="Define the username used to connect through Gmail Server.",
        metavar="USER")

    parser.add_option(
        "-p", "--password", dest="password",
        help="Define the password used to connect through Gmail Server.",
        metavar="PASSWORD")

    parser.add_option(
        "-f", "--from", dest="from_",
        help="Define the field 'From:'.",
        metavar="FROM")

    parser.add_option(
        "-s", "--server", dest="server",
        help="Define the SMTP server (default: smtp.gmail.com).",
        metavar="HOST")

    parser.add_option(
        "-P", "--port", dest="port", type="int",
        help="Define the SMTP port to connect (default: 587).",
        metavar="PORT")

    parser.add_option(
        "-v", "--verbose", dest="verbosity", action="count",
        help="Increments the verbosity.")

    parser.set_defaults(server="smtp.gmail.com")
    parser.set_defaults(port=587)
    (options, args) = parser.parse_args()

    if len(args) != 2:
        parser.error("incorrect number of arguments")

    if options.username is None:
        parser.error("username expected")

    if options.password is None:
        options.password = getpass("Password: ")

    if options.from_ is None:
        sender = options.username
    else:
        sender = options.from_

    # Template
    try:
        mail_f = open(args[0])
    except IOError, ex:
        sys.stderr.write("error: cannot open %s" % args[0])

    subject = ""
    body = []
    start_msg = False
    for line in mail_f.xreadlines():
        line = line.rstrip()

        if line.strip().startswith("Subject: "):
            subject = line.strip().split(": ",1)[1]
            continue

        # strip whitespaces
        if not line and not start_msg:
            continue
        else:
            start_msg = True

        body.append(line)
    mail_f.close()

    template = '\n'.join(body)

    # Database
    try:
        database_f = open(args[1])
    except IOError, ex:
        sys.stderr.write("error: cannot open %s\n" % args[1])
        sys.exit(1)

    email_data = []

    header = ['name', 'email']
    email_col = 0
    counter = 0

    reader = csv.reader(database_f)

    for row in reader:
        counter += 1

        email_col = None
        name_col = None
        if "email" in row:
            header = row
            email_col = header.index("email")
            if "name" in row:
                name_col = header.index("name")
            continue

        if len(row) != len(header):
            sys.stderr.write("ignoring line %s: %s\n" % (counter, ' '.join(row)))
            continue

        email = dict(zip(header, row))
        email_data.append(email)

    database_f.close()

    gmail = Gmail(options.username, options.password, options.server, options.port)
    gmail.debug_level = options.verbosity

    try:
        gmail.connect()
    except smtplib.SMTPAuthenticationError:
        sys.stderr.write("error: authentication error\n")
        sys.exit(1)

    for email in email_data:
        gmail.send(sender, "%(name)s <%(email)s>," % email, subject % email, template % email)
        print "waiting 3 seconds after send an e-mail to %(email)s..." % email
        time.sleep(3)

    gmail.disconnect()
