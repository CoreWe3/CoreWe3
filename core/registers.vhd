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
    in_addr : in std_logic_vector(5 downto 0);
    out_addr1 : in std_logic_vector(5 downto 0);
    out_addr2 : in std_logic_vector(5 downto 0);
    in_word : in std_logic_vector(31 downto 0);
    out_word1 : out std_logic_vector(31 downto 0);
    out_word2 : out std_logic_vector(31 downto 0));
end registers;

architecture arch_registers of registers is

  type ram_t is array(0 to 63) of std_logic_vector(31 downto 0);
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
      if we = '1' and unsigned(in_addr) /= 0 then
        RAM(to_integer(unsigned(in_addr))) <= in_word;
      end if;
    end if;
  end process;

  out_word1 <= RAM(to_integer(unsigned(out_addr1)));
  out_word2 <= RAM(to_integer(unsigned(out_addr2)));

end arch_registers;
