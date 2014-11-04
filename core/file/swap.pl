#!/usr/bin/perl
use strict;
use warnings;
my $instr;
binmode(STDOUT);
while(read(STDIN, $instr, 4)) {
    my @a = unpack("CCCC",$instr);
    print (pack("CCCC", (reverse @a)));
}
