library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity receive_buffer_tb is
end receive_buffer_tb;

architecture tb of receive_buffer_tb is
  component receive_buffer is
    generic(wtime : std_logic_vector := x"0003";
            debug : boolean := true);
    port (
      clk : in std_logic;
      RS_RX : in std_logic;
      go : in std_logic;
      data : out std_logic_vector(31 downto 0);
      busy : out std_logic);
  end component;

  signal clk : std_logic;
  signal RS_RX : std_logic;
  signal go : std_logic;
  signal data : std_logic_vector(31 downto 0);
  signal busy : std_logic;

begin

  main : receive_buffer port map (
    clk => clk,
    RS_RX => RS_RX,
    go => go,
    data => data,
    busy => busy);

  process(clk)
  begin
    if rising_edge(clk) then
      if busy = '0' and go = '0' then
        go <= '1';
      else
        go <= '0';
      end if;
    end if;
  end process;

  process
  begin
    clk <= '1';
    wait for 1 ns;
    clk <= '0';
    wait for 1 ns;
  end process;

end tb;
