-- register unit
-- asynchronous read
-- synchronous write

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registers is
  port (
    clk : in std_logic;
    we : in std_logic;
    ai : in unsigned(5 downto 0);
    ao1 : in unsigned(5 downto 0);
    ao2 : in unsigned(5 downto 0);
    di : in unsigned(31 downto 0);
    do1 : out unsigned(31 downto 0);
    do2 : out unsigned(31 downto 0));
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
      if we = '1' and ai /= 0 then
        RAM(to_integer(ai)) <= di;
      end if;
    end if;
  end process;

  do1 <= RAM(to_integer(do1));
  do2 <= RAM(to_integer(do2));

end arch_registers;
