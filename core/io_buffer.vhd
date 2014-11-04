library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity IO_buffer is
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
end IO_buffer;

architecture arch_io_buffer of IO_buffer is
  component receive_buffer is
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime;
      debug : boolean := debug);
    port (
      clk : in std_logic;
      RS_RX : in std_logic;
      go : in std_logic;
      data : out std_logic_vector(31 downto 0);
      busy : out std_logic);
  end component;

  component transmit_buffer is
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime);
    port (
      clk : in std_logic;
      RS_TX : out std_logic;
      go : in std_logic;
      data : in std_logic_vector(31 downto 0);
      busy : out std_logic);
  end component;

  signal rgo : std_logic := '0';
  signal tgo : std_logic := '0';
  signal rbusy : std_logic;
  signal tbusy : std_logic;

begin

  receive : receive_buffer port map (
    clk => clk,
    RS_RX => RS_RX,
    go => rgo,
    data => receive_data,
    busy => rbusy);

  transmit : transmit_buffer port map (
    clk => clk,
    RS_TX => RS_TX,
    go => tgo,
    data => transmit_data,
    busy => tbusy);

  tgo <= '1' when go = '1' and we = '1' else
         '0';
  rgo <= '1' when go = '1' and we = '0' else
         '0';
  busy <= '1' when tbusy = '1' or rbusy = '1' else
          '0';
  
end arch_io_buffer;                 
