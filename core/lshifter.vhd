library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lshifter is
  port(
    DI: in unsigned(31 downto 0);
    SEL: in unsigned(4 downto 0);
    SO: out unsigned(31 downto 0));
end lshifter;

architecture arch_lshifter of lshifter is
begin
  with SEL select
    SO <= DI  when "00000",
    DI sll  1 when "00001",
    DI sll  2 when "00010",
    DI sll  3 when "00011",
    DI sll  4 when "00100", 
    DI sll  5 when "00101", 
    DI sll  6 when "00110", 
    DI sll  7 when "00111",
    DI sll  8 when "01000", 
    DI sll  9 when "01001", 
    DI sll 10 when "01010", 
    DI sll 11 when "01011", 
    DI sll 12 when "01100", 
    DI sll 13 when "01101", 
    DI sll 14 when "01110", 
    DI sll 15 when "01111", 
    DI sll 16 when "10000", 
    DI sll 17 when "10001", 
    DI sll 18 when "10010", 
    DI sll 19 when "10011", 
    DI sll 20 when "10100", 
    DI sll 21 when "10101", 
    DI sll 22 when "10110", 
    DI sll 23 when "10111", 
    DI sll 24 when "11000", 
    DI sll 25 when "11001", 
    DI sll 26 when "11010", 
    DI sll 27 when "11011", 
    DI sll 28 when "11100", 
    DI sll 29 when "11101", 
    DI sll 30 when "11110", 
    DI sll 31 when others; 

end arch_lshifter;
