library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity read_file_tb is
end read_file_tb;

architecture tb of read_file_tb is
  component read_file is
    generic (
      file_name : string := "data.hex");
    port (
      clk : in std_logic;
      compete : out std_logic;
      data : out std_logic_vector(7 downto 0));
  end component;

  signal clk : std_logic;
  signal compete : std_logic;
  signal data : std_logic_vector(7 downto 0);
begin

  reader : read_file port map (
    clk => clk,
    compete => compete,
    data => data);

  process
  begin
    clk <= '1';
    wait for 1 ns;
    clk <= '0';
    wait for 1 ns;
  end process;
    
end tb;
