library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Util.all;

entity Main is
  generic (
    wtime : std_logic_vector(15 downto 0) := x"023D");
  port (
    clk   : in    std_logic;
    RS_TX : out   std_logic;
    RS_RX : in    std_logic;
    ZD    : inout std_logic_vector(31 downto 0);
    ZA    : out   std_logic_vector(19 downto 0);
    XWA   : out   std_logic);
end Main;

architecture Main_arch of Main is

  component Memory is
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime);
    port (
      clk     : in    std_logic;
      RS_RX   : in    std_logic;
      RS_TX   : out   std_logic;
      ZD      : inout std_logic_vector(31 downto 0);
      ZA      : out   std_logic_vector(19 downto 0);
      XWA     : out   std_logic;
      bus_out : in    bus_out_t;
      bus_in  : out   bus_in_t);
  end component;

  component Control is
    port(
      clk     : in  std_logic;
      bus_in  : in  bus_in_t;
      bus_out : out bus_out_t);
  end component;

  signal bus_in  : bus_in_t;
  signal bus_out : bus_out_t;

begin

  ram_unit : Memory port map (
    clk     => clk,
    RS_RX   => RS_RX,
    RS_TX   => RS_TX,
    ZD      => ZD,
    ZA      => ZA,
    XWA     => XWA,
    bus_out => bus_out,
    bus_in  => bus_in);

  contol_unit : Control port map (
    clk     => clk,
    bus_in  => bus_in,
    bus_out => bus_out);

end Main_arch;
