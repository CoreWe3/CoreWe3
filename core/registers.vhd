-- register unit
-- asynchronous read
-- synchronous write

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity registers is
  port (
    clk : in std_logic;
    rdi : in rreg_in_t;
    wdi : in wreg_in_t;
    do : out reg_out_t);
end registers;

architecture arch_registers of registers is

  type ram_t is array(0 to 63) of unsigned(31 downto 0);
  signal RAM : ram_t := (
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000");

begin
  process(clk)
  begin
    if rising_edge(clk) then
      if wdi.we = '1' and wdi.a /= 0 then
        RAM(to_integer(wdi.a)) <= wdi.d;
      end if;
    end if;
  end process;

  do.d1 <= RAM(to_integer(rdi.a1));
  do.d2 <= RAM(to_integer(rdi.a2));

end arch_registers;
