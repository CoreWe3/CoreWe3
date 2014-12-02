#!/usr/bin/env python
import struct
import sys

def binary(n):
    a = n
    s = ''
    for i in range(8):
        if a%2 == 0:
            s = '0' + s
        else:
            s = '1' + s
        a /= 2
    return s

l = 0
while True :
    w = sys.stdin.read(4)
    s = ''
    if len(w) == 4:
        for t in reversed(struct.unpack('>4B',w)):
            s += binary(t)
        print s
        l += 1
    else:
        break

while l < 256:
    print '00000000000000000000000000000000'
    l += 1

