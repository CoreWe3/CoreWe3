#!/usr/bin/perl
use strict;
use warnings;

my $instr;
my $ite = 0;
my $s = 4;
while(read(STDIN, $instr, 4)){
    my @a = unpack("CCCC", $instr);
    foreach my $bit (@a) {
	printf("%02x", $bit);
    }
    print "\n";
}

for(my $s=0; $s < 20000; $s++){
    print "18000000\n"; #nop
}
