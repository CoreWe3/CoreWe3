library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity sram_tb is
end sram_tb;

architecture arch_sram_tb of sram_tb is
  component sram is
    port (
      clk : in std_logic;
      ZD : inout std_logic_vector(31 downto 0);
      ZA : in std_logic_vector(19 downto 0);
      XWA : in std_logic);
  end component;

  signal clk : std_logic;
  signal ZD : std_logic_vector(31 downto 0) := (others => '0');
  signal ZA : std_logic_vector(19 downto 0) := (others => '0');
  signal XWA : std_logic := '1';
  signal state : std_logic_vector(2 downto 0) := (others => '0');
begin

  process
  begin
    clk <= '1';
    wait for 1 ns;
    clk <= '0';
    wait for 1 ns;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      case state is
        when "000" =>
          XWA <= '0';
        when "001" =>
          XWA <= '1';
        when "010" =>
        when "011" =>
        when "100" =>
        when "101" =>
        when others =>
      end case;
      state <= state+1;
    end if;
  end process;

  sram_sim : SRAM port map
    (clk => clk,
     ZD => ZD,
     ZA => ZA,
     XWA => XWA);

end arch_sram_tb;
    
  
