-- alu unit
-- logical shift

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
  port (
    di1 : in unsigned(31 downto 0);
    di2 : in unsigned(31 downto 0);
    do : out unsigned(31 downto 0);
    ctrl : in std_logic_vector(2 downto 0));
end alu;

architecture arch_alu of alu is

begin

  do <= di1 + di2 when ctrl = "000" else
        di1 - di2 when ctrl = "001" else
        di1 and di2 when ctrl = "010" else
        di1 or di2 when ctrl = "011" else
        di1 xor di2 when ctrl = "100" else
        shift_left(di1, to_integer(di2(4 downto 0)))
        when ctrl = "101" and di2(31 downto 5) = 0 else
        shift_right(di1, to_integer(di2(4 downto 0)))
        when ctrl = "110" and di2(31 downto 5) = 0 else
        x"00000000";

end arch_alu;
