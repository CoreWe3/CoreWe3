library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;

entity core is
  port (
    MCLK1  : in    std_logic;
    RS_RX  : in    std_logic;
    RS_TX  : out   std_logic;
    ZD     : inout std_logic_vector(31 downto 0);
    ZA     : out   std_logic_vector(19 downto 0);
    XE1    : out   std_logic;
    E2A    : out   std_logic;
    XE3    : out   std_logic;
    XZBE   : out   std_logic_vector(3 downto 0);
    XGA    : out   std_logic;
    XWA    : out   std_logic;
    XZCKE  : out   std_logic;
    ZCLKMA : out   std_logic_vector(1 downto 0);
    ADVA   : out   std_logic;
    XFT    : out   std_logic;
    XLBO   : out   std_logic;
    ZZA    : out   std_logic);
end core;

architecture arch_core of core is
  component core_main
    generic (
      CODE : string := "file/fib_rec.tbin";
      ADDR_WIDTH : integer := 8;
      CLKR : integer := 2;
      memCPB : integer := 1146;
      --wtime : std_logic_vector(15 downto 0) := x"047A";
      --wtime : std_logic_vector(15 downto 0) := x"023D";
      debug : boolean := false);
    port (
      sysclk : in    std_logic;
      memclk : in     std_logic;
      RS_TX  : out   std_logic;
      RS_RX  : in    std_logic;
      ZD     : inout std_logic_vector(31 downto 0);
      ZA     : out   std_logic_vector(19 downto 0);
      XWA    : out   std_logic);
  end component;

  signal iclk : std_logic;
  signal gmemclk : std_logic;
  signal gsysclk : std_logic;
  signal fbclk : std_logic;
  signal bfbclk : std_logic;
  signal sysclk : std_logic;
  signal memclk : std_logic;
begin  -- arch_core

  ib : IBUFG port map (
    i => MCLK1,
    o => iclk);

  bg0 : BUFG port map (
    i => gmemclk,
    o => memclk);

  bg1 : BUFG port map (
    i => bfbclk,
    o => fbclk);

  bg2 : BUFG port map (
    i => gsysclk,
    o => sysclk);

  dcm : DCM_BASE
  generic map (
    CLKFX_MULTIPLY => 4)
  port map (
    CLKIN => iclk,
    CLKFB => fbclk,
    RST => '0',
    CLK0 => bfbclk,
    CLK90 => open,
    CLK180 => open,
    CLK270 => open,
    CLK2X => gmemclk,
    CLK2X180 => open,
    CLKDV => open,
    CLKFX => gsysclk,
    CLKFX180 => open,
    LOCKED => open);

  main : core_main port map (
    sysclk => sysclk,
    memclk => memclk,
    RS_TX  => RS_TX,
    RS_RX  => RS_RX,
    ZD     => ZD,
    ZA     => ZA,
    XWA    => XWA);

  XE1 <= '0';
  E2A <= '1';
  XE3 <= '0';
  XZBE <= "0000";
  XGA <= '0';
  XZCKE <= '0';
  ZCLKMA(0) <= memclk;
  ZCLKMA(1) <= memclk;
  ADVA <= '0';
  XFT <= '1';
  XLBO <= '1';
  ZZA <= '0';

end arch_core;
