library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity leading_zero_counter is
  port (
    data : in unsigned(27 downto 0);
    n : out unsigned(4 downto 0));
  attribute priority_extract : string;
  attribute priority_extract of leading_zero_counter :
    entity is "force";
end leading_zero_counter;


architecture arch_LZC of leading_zero_counter is
begin
  n <= "00000" when data(27) = '1' else
       "00001" when data(26) = '1' else
       "00010" when data(25) = '1' else
       "00011" when data(24) = '1' else
       "00100" when data(23) = '1' else
       "00101" when data(22) = '1' else
       "00110" when data(21) = '1' else
       "00111" when data(20) = '1' else
       "01000" when data(19) = '1' else
       "01001" when data(18) = '1' else
       "01010" when data(17) = '1' else
       "01011" when data(16) = '1' else
       "01100" when data(15) = '1' else
       "01101" when data(14) = '1' else
       "01110" when data(13) = '1' else
       "01111" when data(12) = '1' else
       "10000" when data(11) = '1' else
       "10001" when data(10) = '1' else
       "10010" when data( 9) = '1' else
       "10011" when data( 8) = '1' else
       "10100" when data( 7) = '1' else
       "10101" when data( 6) = '1' else
       "10110" when data( 5) = '1' else
       "10111" when data( 4) = '1' else
       "11000" when data( 3) = '1' else
       "11001";
end arch_LZC;
