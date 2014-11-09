library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity uart_transmitter_test is
  port (
    clk: in std_logic;
    RS_TX : out std_logic);
end uart_transmitter_test;

architecture test_arch of uart_transmitter_test is
  component uart_transmitter is
    port (
      clk : in std_logic;
      data : in std_logic_vector(7 downto 0);
      go : in std_logic;
      busy : out std_logic;
      tx : out std_logic);
  end component;

  signal data : std_logic_vector(7 downto 0) := x"41";
  signal go : std_logic;
  signal busy : std_logic;
begin

  test : uart_transmitter port map(
    clk => clk,
    data => data,
    go => go,
    busy => busy,
    tx => RS_TX);

  process(clk)
  begin
    if rising_edge(clk) then
      if busy = '0' and go = '0' then
        go <= '1';
        if data = x"5A" then
          data <= x"41";
        else
          data <= data+1;
        end if;
      else
        go <= '0';
      end if;
    end if;
  end process;

end test_arch;  
