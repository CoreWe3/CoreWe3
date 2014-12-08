#!/usr/bin/env python
import struct
import sys

l = 0
while True :
    w = sys.stdin.read(4)
    s = ''
    if len(w) == 4:
        for t in reversed(struct.unpack('>4B',w)):
            s += bin(t)[2:].zfill(8)
        print s
        l += 1
    else:
        break

while l < 2 ** int(sys.argv[1]):
    print '00000000000000000000000000000000'
    l += 1

