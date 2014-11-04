library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity loopback is
  generic (
    wtime : std_logic_vector(15 downto 0) := x"1ADB");
  port (
    clk : in std_logic;
    RS_RX : in std_logic;
    RS_TX : out std_logic);
end loopback;

architecture arch_loopback of loopback is
  component uart_transmitter is
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime);
    port (
      clk : in std_logic;
      data : in std_logic_vector(7 downto 0);
      go : in std_logic;
      busy : out std_logic;
      tx : out std_logic);
  end component;

  component uart_receiver is
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime);
    port (
      clk : in std_logic;
      rx : in std_logic;
      complete : out std_logic;
      data : out std_logic_vector(7 downto 0));
  end component;
  
  signal data : std_logic_vector(7 downto 0);  
  signal go : std_logic := '0';
  signal busy : std_logic;
  signal complete : std_logic;
  
begin

  transmit : uart_transmitter port map (
    clk => clk,
    data => data,
    go => go,
    busy => busy,
    tx => RS_TX);
  
  receive : uart_receiver port map (
    clk => clk,
    rx => RS_RX,
    complete => complete,
    data => data);
  
  process(clk)
  begin
    if rising_edge(clk) then
      if complete = '1' and go = '0' and busy = '0' then
        go <= '1';
      else
        go <= '0';
      end if;
    end if;
  end process;
end arch_loopback;
