#!/bin/sh
hexdump -v -e '"%07.7_ax " 4/1 "%02x " "\n"' $1
