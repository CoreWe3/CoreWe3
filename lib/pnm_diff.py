#!/usr/bin/python
import re
import sys
import struct

if __name__ == "__main__":
    f1 = open(sys.argv[1], 'rb')
    f2 = open(sys.argv[2], 'rb')
    s1 = f1.read()
    s2 = f2.read()
    f1.close()
    f2.close()
    
    pat_header = re.compile(r'^P\d[ \n]\d+[ \n]\d+[ \n]255[ \n]', re.M)
    m1 = pat_header.search(s1)
    if m1 == None:
        raise Exception(sys.argv[1] + " is invalid pnm file")
    m2 = pat_header.search(s2)
    if m2 == None:
        raise Exception(sys.argv[2] + " is invalid pnm file")
    if m1.group() != m2.group():
        raise Exception("These files are not same size.")

    l1 = s1[m1.end():]
    l2 = s2[m2.end():]
    sys.stdout.write(m1.group())
    for i in range(len(s1)):
        c1 = ord(s1[i])
        c2 = ord(s2[i])
        sys.stdout.write(chr(255-abs(c1-c2)))
        
