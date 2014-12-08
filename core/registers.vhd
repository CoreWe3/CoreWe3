-- register unit
-- asynchronous read
-- synchronous write

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

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

  type ram_t is array(63 downto 0) of std_logic_vector(31 downto 0);
  signal RAM : ram_t;
       
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if we = '1' and in_addr /= "000000" then
        RAM(conv_integer(in_addr)) <= in_word;
      end if;
    end if;
  end process;

  out_word1 <= RAM(conv_integer(out_addr1)) when out_addr1 /= "000000" else
               (others => '0');
  out_word2 <= RAM(conv_integer(out_addr2)) when out_addr2 /= "000000" else
               (others => '0');

end arch_registers;
  
