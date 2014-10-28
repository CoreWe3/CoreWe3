library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity loopback_tb is
  generic(
    wtime : std_logic_vector(15 downto 0) := x"000E");
end loopback_tb;

architecture test_arch of loopback_tb is
  component loopback is
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime);
    port (
      clk : in std_logic;
      RS_RX : in std_logic;
      RS_TX : out std_logic);
  end component;
   
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

  signal clk : std_logic;
  signal RS_RX : std_logic;
  signal RS_TX : std_logic;
  signal busy : std_logic;
  signal go : std_logic := '0';
  signal complete : std_logic;
  signal datain : std_logic_vector(7 downto 0) := x"41";
  signal dataout : std_logic_vector(7 downto 0);

begin

  main : loopback port map (
    clk => clk,
    RS_RX => RS_RX,
    RS_TX => RS_TX);

  serialin : uart_transmitter port map (
    clk => clk,
    data => datain,
    go => go,
    busy => busy,
    tx => RS_RX);

  serialout : uart_receiver port map (
    clk => clk,
    rx => RS_TX,
    complete => complete,
    data => dataout);

  inprocess : process(clk)
  begin
    if rising_edge(clk) then
      if busy = '0' and go = '0' then
        go <= '1';
        datain <= datain+1;
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

end test_arch;
