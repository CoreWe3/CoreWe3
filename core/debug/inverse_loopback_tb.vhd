library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity inverse_loopback_tb is
end inverse_loopback_tb;

architecture arch_test of inverse_loopback_tb is
  component uart_receiver is
    generic (
      wtime : std_logic_vector(15 downto 0) := x"000E");
    port (
      clk : in std_logic;
      rx : in std_logic;
      complete : out std_logic;
      data : out std_logic_vector(7 downto 0));
  end component;

  component uart_transmitter is
    generic (
      wtime : std_logic_vector(15 downto 0) := x"000E");
    port (
      clk : in std_logic;
      data : in std_logic_vector(7 downto 0);
      go : in std_logic;
      busy : out std_logic;
      tx : out std_logic);
  end component;

  signal clk : std_logic;
  signal indata : std_logic_vector(7 downto 0) := x"41";
  signal outdata : std_logic_vector(7 downto 0);
  signal serial : std_logic;
  signal complete : std_logic;
  signal go : std_logic := '0';
  signal busy : std_logic;
  
  
begin

  transmit : uart_transmitter port map (
    clk => clk,
    data => indata,
    go => go,
    busy => busy,
    tx => serial);

  receive : uart_receiver port map (
    clk => clk,
    rx => serial,
    complete => complete,
    data => outdata);

  process(clk)
  begin
    if rising_edge(clk) then
      if busy = '0' and go = '0' then
        go <= '1';
        if indata = x"5A" then
          indata <= x"41";
        else
          indata <= indata+1;
        end if;
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

end arch_test;
      
