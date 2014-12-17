-- alu unit
-- logical shift

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.util.all;

entity alu is
  port (
    di : in alu_in_t;
    do : out alu_out_t);
end alu;

architecture arch_alu of alu is

begin

  do.d <= di.d1 + di.d2 when di.ctrl = "000" else
          di.d1 - di.d2 when di.ctrl = "001" else
          di.d1 and di.d2 when di.ctrl = "010" else
          di.d1 or di.d2 when di.ctrl = "011" else
          di.d1 xor di.d2 when di.ctrl = "100" else
          shift_left(di.d1, to_integer(di.d2(4 downto 0)))
          when di.ctrl = "101" and di.d2(31 downto 5) = 0 else
          shift_right(di.d1, to_integer(di.d2(4 downto 0)))
          when di.ctrl = "110" and di.d2(31 downto 5) = 0 else
          x"00000000";

end arch_alu;
