library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library work;
use work.util.all;

entity code_rom_tb is
end code_rom_tb;

architecture arch_code_rom_tb of code_rom_tb is
  component code_rom_test
    port ( clk : in std_logic;
           RS_TX : out std_logic);
  end component;

  signal clk : std_logic;
  signal rstx : std_logic;
begin

  code : code_rom_test port map (
    clk => clk,
    RS_TX => rstx);

  process
  begin
    clk <= '0';
    wait for 1 ns;
    clk <= '1';
    wait for 1 ns;
  end process;

end arch_code_rom_tb;
