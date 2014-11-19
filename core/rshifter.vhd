library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rshifter is
  port(
    DI: in unsigned(31 downto 0);
    SEL: in unsigned(4 downto 0);
    SO: out unsigned(31 downto 0));
end rshifter;

architecture arch_rshifter of rshifter is
begin
  with SEL select
    SO <= DI  when "00000",
    DI srl  1 when "00001",
    DI srl  2 when "00010",
    DI srl  3 when "00011",
    DI srl  4 when "00100", 
    DI srl  5 when "00101", 
    DI srl  6 when "00110", 
    DI srl  7 when "00111",
    DI srl  8 when "01000", 
    DI srl  9 when "01001", 
    DI srl 10 when "01010", 
    DI srl 11 when "01011", 
    DI srl 12 when "01100", 
    DI srl 13 when "01101", 
    DI srl 14 when "01110", 
    DI srl 15 when "01111", 
    DI srl 16 when "10000", 
    DI srl 17 when "10001", 
    DI srl 18 when "10010", 
    DI srl 19 when "10011", 
    DI srl 20 when "10100", 
    DI srl 21 when "10101", 
    DI srl 22 when "10110", 
    DI srl 23 when "10111", 
    DI srl 24 when "11000", 
    DI srl 25 when "11001", 
    DI srl 26 when "11010", 
    DI srl 27 when "11011", 
    DI srl 28 when "11100", 
    DI srl 29 when "11101", 
    DI srl 30 when "11110", 
    DI srl 31 when others; 

end arch_rshifter;
