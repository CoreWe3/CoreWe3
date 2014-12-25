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
  component core_main is
    generic (
      CODE : string := "file/test.bin";
      wtime : std_logic_vector(15 downto 0) := x"023D");
    port (
      clk   : in    std_logic;
      RS_TX : out   std_logic;
      RS_RX : in    std_logic;
      ZD    : inout std_logic_vector(31 downto 0);
      ZA    : out   std_logic_vector(19 downto 0);
      XWA   : out   std_logic);
  end component;

  signal iclk : std_logic;
  --signal fbclk : std_logic;
  --signal bfbclk : std_logic;
  --signal gsysclk : std_logic;
  signal sysclk : std_logic;
  --signal gmemclk : std_logic;
  --signal memclk : std_logic;
begin  -- arch_core

  ib : IBUFG port map (
    i => MCLK1,
    o => iclk);

  bg0 : BUFG port map (
    i => iclk,
    o => sysclk);

  --bg0 : BUFG port map (
  --  i => gsysclk,
  --  o => sysclk);

  --bg1 : BUFG port map (
  --  i => fbclk,
  --  o => bfbclk);

  --dcm : DCM_BASE port map (
  --  CLKIN => iclk,
  --  CLKFB => bfbclk,
  --  RST => '0',
  --  CLK0 => fbclk,
  --  CLK90 => open,
  --  CLK180 => open,
  --  CLK270 => open,
  --  CLK2X => gsysclk,
  --  CLK2X180 => open,
  --  CLKDV => open,
  --  CLKFX => open,
  --  CLKFX180 => open,
  --  LOCKED => open);

  --pll : PLL_BASE
  --  generic map (
  --    CLKOUT0_DIVIDE => 4,
  --    CLKOUT0_DIVIDE => 4,
  --    CLKFBOUT_MULT => 8,
  --    CLKIN_PERIOD => 14.50)
  --  port map (
  --    CLKIN => iclk,
  --    CLKFBIN => fbclk,
  --    RST => '0',
  --    CLKOUT0 => gsysclk,
  --    CLKOUT1 => gmemclk,
  --    CLKOUT2 => open,
  --    CLKOUT3 => open,
  --    CLKOUT4 => open,
  --    CLKOUT5 => open,
  --    CLKFBOUT => fbclk,
  --    LOCKED => open);

  main : core_main port map (
    clk   => sysclk,
    RS_TX => RS_TX,
    RS_RX => RS_RX,
    ZD    => ZD,
    ZA    => ZA,
    XWA   => XWA);

  XE1 <= '0';
  E2A <= '1';
  XE3 <= '0';
  XZBE <= "0000";
  XGA <= '0';
  XZCKE <= '0';
  ZCLKMA(0) <= sysclk;
  ZCLKMA(1) <= sysclk;
  ADVA <= '0';
  XFT <= '1';
  XLBO <= '1';
  ZZA <= '0';

end arch_core;
