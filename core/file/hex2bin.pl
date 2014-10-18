#!/usr/bin/perl
use strict;
use warnings;
while(<>) {
    s/([0-9a-f])/bin($1)/eg;
    print;
}

# my $s = "0110FFFF\n";
# $s =~ s/([0-9A-F])/bin($1)/eg;
# for(my $i = 0; $i < 30000; $i++){
#     print $s;
# }

sub bin {
    if ($_[0] eq "0") { return "0000";}
    elsif ($_[0] eq "1") { return "0001";} 
    elsif ($_[0] eq "2") { return "0010";} 
    elsif ($_[0] eq "3") { return "0011";} 
    elsif ($_[0] eq "4") { return "0100";} 
    elsif ($_[0] eq "5") { return "0101";} 
    elsif ($_[0] eq "6") { return "0110";} 
    elsif ($_[0] eq "7") { return "0111";} 
    elsif ($_[0] eq "8") { return "1000";} 
    elsif ($_[0] eq "9") { return "1001";} 
    elsif ($_[0] eq "a") { return "1010";} 
    elsif ($_[0] eq "b") { return "1011";} 
    elsif ($_[0] eq "c") { return "1100";} 
    elsif ($_[0] eq "d") { return "1101";} 
    elsif ($_[0] eq "e") { return "1110";} 
    elsif ($_[0] eq "f") { return "1111";} 
    else { return "XXXX"; }
}
