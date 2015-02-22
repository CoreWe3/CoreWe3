import sys
import struct

def convert01(instruction):
    str01 = ''
    for byte in reversed(struct.unpack("4B", instruction)):
        str01 += bin(byte)[2:].zfill(8)
    return str01


for i in range(2**12):
    instruction = sys.stdin.read(4)
    if len(instruction) == 4:
        print convert01(instruction)
    else:
        print "00011000000000000000000000000000"
