library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity bram_tb is
end bram_tb;

architecture arch of bram_tb is

  component bram is
    port (
      clk : in std_logic;
      di : in std_logic_vector(31 downto 0);
      do : out std_logic_vector(31 downto 0);
      addr : in std_logic_vector(11 downto 0);
      we : in std_logic);
  end component;

  signal clk : std_logic;
  -- signal di : std_logic_vector(31 downto 0);
  signal do : std_logic_vector(31 downto 0);
  signal addr : std_logic_vector(11 downto 0) := (others => '0');
  signal we : std_logic := '0';

begin

  main : bram port map(
    clk => clk,
    di => x"00000000",
    do => do,
    addr => addr,
    we => we);

  clkgen : process
  begin
    clk <= '1';
    wait for 1 ps;
    clk <= '0';
    wait for 1 ps;
  end process;

  ctrl : process(clk)
  begin
    if rising_edge(clk) then
      addr <= addr + 1;
    end if;
  end process;

end arch;
