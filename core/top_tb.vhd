library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity top_tb is
end top_tb;

architecture arch of top_tb is
  component IO_buffer_loopback is
    generic (wtime : std_logic_vector(15 downto 0) := x"0003";
             debug : boolean := true);
    port (
      clk : in std_logic;
      RS_RX : in std_logic;
      RS_TX : out std_logic);
  end component;

  signal clk : std_logic;
  signal RS_RX : std_logic;
  signal RS_TX : std_logic;
begin

  main : IO_buffer_loopback port map
    (clk => clk,
     RS_RX => RS_RX,
     RS_TX => RS_TX);

  process
  begin
    clk <= '1';
    wait for 1 ns;
    clk <= '0';
    wait for 1 ns;
  end process;
end arch;
    
