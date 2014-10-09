library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;

entity alu is
  port (
    in_word1 : in std_logic_vector(31 downto 0);
    in_word2 : in std_logic_vector(31 downto 0);
    out_word : out std_logic_vector(31 downto 0);
    ctrl : in std_logic_vector(2 downto 0));
end alu;

architecture arch_alu of alu is
  signal shiftl : std_logic_vector(31 downto 0);
  signal shiftr : std_logic_vector(31 downto 0);
  signal zero : std_logic_vector(31 downto 0) := (others => '0');
begin
  
  out_word <= in_word1 + in_word2 when ctrl = "000" else
              in_word1 - in_word2 when ctrl = "001" else
              in_word1 and in_word2 when ctrl = "010" else
              in_word1 or in_word2 when ctrl = "011" else
              in_word1 xor in_word2 when ctrl = "100" else
              shiftl when ctrl = "101" else
              shiftr when ctrl = "110";

  shiftl <= in_word1 when in_word2 = x"0000000" else
            in_word1(30 downto 0) & zero(31 downto 31) when in_word2 =  x"00000001" else
            in_word1(29 downto 0) & zero(31 downto 30) when in_word2 =  x"00000002" else
            in_word1(28 downto 0) & zero(31 downto 29) when in_word2 =  x"00000003" else
            in_word1(27 downto 0) & zero(31 downto 28) when in_word2 =  x"00000004" else
            in_word1(26 downto 0) & zero(31 downto 27) when in_word2 =  x"00000005" else
            in_word1(25 downto 0) & zero(31 downto 26) when in_word2 =  x"00000006" else
            in_word1(24 downto 0) & zero(31 downto 25) when in_word2 =  x"00000007" else
            in_word1(23 downto 0) & zero(31 downto 24) when in_word2 =  x"00000008" else
            in_word1(22 downto 0) & zero(31 downto 23) when in_word2 =  x"00000009" else
            in_word1(21 downto 0) & zero(31 downto 22) when in_word2 =  x"0000000A" else
            in_word1(20 downto 0) & zero(31 downto 21) when in_word2 =  x"0000000B" else
            in_word1(19 downto 0) & zero(31 downto 20) when in_word2 =  x"0000000C" else
            in_word1(18 downto 0) & zero(31 downto 19) when in_word2 =  x"0000000D" else
            in_word1(17 downto 0) & zero(31 downto 18) when in_word2 =  x"0000000E" else
            in_word1(16 downto 0) & zero(31 downto 17) when in_word2 =  x"0000000F" else
            in_word1(15 downto 0) & zero(31 downto 16) when in_word2 =  x"00000010" else
            in_word1(14 downto 0) & zero(31 downto 15) when in_word2 =  x"00000011" else
            in_word1(13 downto 0) & zero(31 downto 14) when in_word2 =  x"00000012" else
            in_word1(12 downto 0) & zero(31 downto 13) when in_word2 =  x"00000013" else
            in_word1(11 downto 0) & zero(31 downto 12) when in_word2 =  x"00000014" else
            in_word1(10 downto 0) & zero(31 downto 11) when in_word2 =  x"00000015" else
            in_word1(9  downto 0) & zero(31 downto 10) when in_word2 =  x"00000016" else
            in_word1(8  downto 0) & zero(31 downto 9 ) when in_word2 =  x"00000017" else
            in_word1(7  downto 0) & zero(31 downto 8 ) when in_word2 =  x"00000018" else
            in_word1(6  downto 0) & zero(31 downto 7 ) when in_word2 =  x"00000019" else
            in_word1(5  downto 0) & zero(31 downto 6 ) when in_word2 =  x"0000001A" else
            in_word1(4  downto 0) & zero(31 downto 5 ) when in_word2 =  x"0000001B" else
            in_word1(3  downto 0) & zero(31 downto 4 ) when in_word2 =  x"0000001C" else
            in_word1(2  downto 0) & zero(31 downto 3 ) when in_word2 =  x"0000001D" else
            in_word1(1  downto 0) & zero(31 downto 2 ) when in_word2 =  x"0000001E" else
            in_word1(0  downto 0) & zero(31 downto 1 ) when in_word2 =  x"0000001F" else
            zero;

  shiftr <= in_word1 when in_word2 = x"00000000" else
            zero(0  downto 0) & in_word1(31 downto  1) when in_word2 = x"00000001" else 
            zero(1  downto 0) & in_word1(31 downto  2) when in_word2 = x"00000002" else 
            zero(2  downto 0) & in_word1(31 downto  3) when in_word2 = x"00000003" else 
            zero(3  downto 0) & in_word1(31 downto  4) when in_word2 = x"00000004" else 
            zero(4  downto 0) & in_word1(31 downto  5) when in_word2 = x"00000005" else 
            zero(5  downto 0) & in_word1(31 downto  6) when in_word2 = x"00000006" else 
            zero(6  downto 0) & in_word1(31 downto  7) when in_word2 = x"00000007" else 
            zero(7  downto 0) & in_word1(31 downto  8) when in_word2 = x"00000008" else 
            zero(8  downto 0) & in_word1(31 downto  9) when in_word2 = x"00000009" else 
            zero(9  downto 0) & in_word1(31 downto 10) when in_word2 = x"0000000A" else 
            zero(10 downto 0) & in_word1(31 downto 11) when in_word2 = x"0000000B" else 
            zero(11 downto 0) & in_word1(31 downto 12) when in_word2 = x"0000000C" else 
            zero(12 downto 0) & in_word1(31 downto 13) when in_word2 = x"0000000D" else 
            zero(13 downto 0) & in_word1(31 downto 14) when in_word2 = x"0000000E" else 
            zero(14 downto 0) & in_word1(31 downto 15) when in_word2 = x"0000000F" else 
            zero(15 downto 0) & in_word1(31 downto 16) when in_word2 = x"00000010" else 
            zero(16 downto 0) & in_word1(31 downto 17) when in_word2 = x"00000011" else 
            zero(17 downto 0) & in_word1(31 downto 18) when in_word2 = x"00000012" else 
            zero(18 downto 0) & in_word1(31 downto 19) when in_word2 = x"00000013" else 
            zero(19 downto 0) & in_word1(31 downto 20) when in_word2 = x"00000014" else 
            zero(20 downto 0) & in_word1(31 downto 21) when in_word2 = x"00000015" else 
            zero(21 downto 0) & in_word1(31 downto 22) when in_word2 = x"00000016" else 
            zero(22 downto 0) & in_word1(31 downto 23) when in_word2 = x"00000017" else 
            zero(23 downto 0) & in_word1(31 downto 24) when in_word2 = x"00000018" else 
            zero(24 downto 0) & in_word1(31 downto 25) when in_word2 = x"00000019" else 
            zero(25 downto 0) & in_word1(31 downto 26) when in_word2 = x"0000001A" else 
            zero(26 downto 0) & in_word1(31 downto 27) when in_word2 = x"0000001B" else 
            zero(27 downto 0) & in_word1(31 downto 28) when in_word2 = x"0000001C" else 
            zero(28 downto 0) & in_word1(31 downto 29) when in_word2 = x"0000001D" else 
            zero(29 downto 0) & in_word1(31 downto 30) when in_word2 = x"0000001E" else 
            zero(30 downto 0) & in_word1(31 downto 31) when in_word2 = x"0000001F" else
            zero;
  
end arch_alu;
