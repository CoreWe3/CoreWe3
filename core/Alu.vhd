-- alu unit
-- logical shift

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.Util.all;

entity Alu is
  port (
    di : in alu_in_t;
    do : out alu_out_t);
end Alu;

architecture Alu_arch of Alu is

begin

  do.d <= di.d1 + di.d2 when di.ctrl = "00" else
          di.d1 - di.d2 when di.ctrl = "01" else
          shift_left(di.d1, to_integer(di.d2(4 downto 0)))
          when di.ctrl = "10" and di.d2(31 downto 5) = 0 else
          shift_right(di.d1, to_integer(di.d2(4 downto 0)))
          when di.ctrl = "11" and di.d2(31 downto 5) = 0 else
          x"00000000";

end Alu_arch;
