import sys
import struct

def convert_endian(instruction):
    struct.pack("4B", reversed(struct.unpack("4B", instruction)))

for i in range(2**10):
    instruction = sys.stdin.read(4)
    if len(instruction) == 4:
        print convert_endian(instruction)
    else:
        sys.exit()

raise Exception("too many instruction")
