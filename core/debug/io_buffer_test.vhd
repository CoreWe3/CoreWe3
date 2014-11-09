library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity IO_buffer_test is
  port (
    clk : in std_logic;
    RS_RX : in std_logic;
    RS_TX : out std_logic);
end IO_buffer_test;

architecture arch_test of IO_buffer_test is
  component IO_buffer is
    generic (
      wtime : std_logic_vector(15 downto 0) := x"1ADB";
      debug : boolean := false);
    port (
      clk : in std_logic;
      RS_RX : in std_logic;
      RS_TX : out std_logic;
      we : in std_logic;
      go : in std_logic;
      transmit_data : in std_logic_vector(31 downto 0);
      receive_data : out std_logic_vector(31 downto 0);
      busy : out std_logic);
  end component;

  signal go : std_logic := '0';
  signal busy : std_logic;

begin

  main : IO_buffer port map (
    clk => clk,
    RS_RX => RS_RX,
    RS_TX => RS_TX,
    we => '1',
    go => go,
    transmit_data => x"61626364",
    receive_data => open,
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
    
end arch_test;
