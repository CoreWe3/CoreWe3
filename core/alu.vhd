-- alu unit
-- logical shift

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity alu is
  port (
    in_word1 : in std_logic_vector(31 downto 0);
    in_word2 : in std_logic_vector(31 downto 0);
    out_word : out std_logic_vector(31 downto 0);
    ctrl : in std_logic_vector(2 downto 0));
end alu;

architecture arch_alu of alu is
begin

  out_word <= in_word1 + in_word2 when ctrl = "000" else
              in_word1 - in_word2 when ctrl = "001" else
              in_word1 and in_word2 when ctrl = "010" else
              in_word1 or in_word2 when ctrl = "011" else
              in_word1 xor in_word2 when ctrl = "100" else
              std_logic_vector(
                shift_left(unsigned(in_word1),
                           to_integer(unsigned(in_word2(4 downto 0)))))
              when ctrl = "101" and in_word2(31 downto 5) = 0 else
              std_logic_vector(
                shift_right(unsigned(in_word1),
                            to_integer(unsigned(in_word2(4 downto 0)))))
              when ctrl = "110" and in_word2(31 downto 5) = 0 else
              x"00000000";

end arch_alu;
