library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity memory_io is
  generic(
    CPB : integer := 1146;
    debug : boolean := false);
  port (
    memclk        : in    std_logic;
    RS_RX      : in    std_logic;
    RS_TX      : out   std_logic;
    ZD         : inout std_logic_vector(31 downto 0);
    ZA         : out   std_logic_vector(19 downto 0);
    XWA        : out   std_logic;
    store_data : in    std_logic_vector(31 downto 0);
    load_data  : out   std_logic_vector(31 downto 0);
    addr       : in    std_logic_vector(19 downto 0);
    we         : in    std_logic;
    go         : in    std_logic;
    busy       : out   std_logic);
end memory_io;

architecture arch_memory_io of memory_io is

  component IO_buffer is
    generic (
      wtime : std_logic_vector(15 downto 0) :=
      conv_std_logic_vector(CPB, 16);
      debug : boolean := debug);
    port (
      clk           : in  std_logic;
      RS_RX         : in  std_logic;
      RS_TX         : out std_logic;
      we            : in  std_logic;
      go            : in  std_logic;
      transmit_data : in  std_logic_vector(7 downto 0);
      receive_data  : out std_logic_vector(7 downto 0);
      busy : out std_logic);
  end component;

  component ram_controller is
    port (
      clk    : in    std_logic;
      ZD     : inout std_logic_vector(31 downto 0);
      ZA     : out   std_logic_vector(19 downto 0);
      XWA    : out   std_logic;
      input  : in    std_logic_vector(31 downto 0);
      output : out   std_logic_vector(31 downto 0);
      addr   : in    std_logic_vector(19 downto 0);
      we     : in    std_logic;
      go     : in    std_logic;
      busy   : out   std_logic);
  end component;

  signal state : std_logic := '0';
  signal iogo : std_logic := '0';
  signal ioload_data : std_logic_vector(7 downto 0);
  signal iobusy : std_logic;

  signal ramgo : std_logic := '0';
  signal ramload_data : std_logic_vector(31 downto 0);
  signal rambusy : std_logic;
    
begin

  IO : IO_buffer port map (
    clk           => memclk,
    RS_RX         => RS_RX,
    RS_TX         => RS_TX,
    we            => we,
    go            => iogo,
    transmit_data => store_data(7 downto 0),
    receive_data  => ioload_data,
    busy          => iobusy);

  ram : ram_controller port map (
    clk    => memclk,
    ZD     => ZD,
    ZA     => ZA,
    XWA    => XWA,
    input  => store_data,
    output => ramload_data,
    addr   => addr,
    we     => we,
    go     => ramgo,
    busy   => rambusy);

  iogo <= go when addr = x"FFFFF" else
          '0';
  ramgo <= go when addr /= x"FFFFF" else
           '0';
  load_data <= x"000000" & ioload_data when state = '0' else
               ramload_data;
  busy <= iobusy or rambusy;

  process(memclk)
  begin
    if rising_edge(memclk) then
      if we = '0' and go = '1' then
        if addr = x"FFFFF" then --io
          state <= '0';
        else --ram
          state <= '1';
        end if;
      end if;
    end if;
  end process;
  
end arch_memory_io;
