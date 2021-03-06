library ieee;
use ieee.std_logic_1164.all;

library UNISIM;
use UNISIM.VComponents.all;

entity Core is
  generic (
    DEBUG : boolean := true;
    wtime : std_logic_vector(15 downto 0) := x"023D"); -- 66MHz
    --wtime : std_logic_vector(15 downto 0) := x"0364" -- 100MHz M=3 D=2
    -- wtime : std_logic_vector(15 downto 0) := x"03f5"; -- 116.66MHz M=7 D=4
    -- wtime : std_logic_vector(15 downto 0) := x"047A"; -- 133MHz
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
end Core;

architecture Core_arch of Core is
  component Main is
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime);
    port (
      clk   : in    std_logic;
      RS_TX : out   std_logic;
      RS_RX : in    std_logic;
      ZD    : inout std_logic_vector(31 downto 0);
      ZA    : out   std_logic_vector(19 downto 0);
      XWA   : out   std_logic);
  end component;

  signal iclk : std_logic;
  signal fbclk : std_logic;
  signal bfbclk : std_logic;
  signal gsysclk : std_logic;
  signal sysclk : std_logic;

begin  -- arch_core

  ib : IBUFG port map (
    i => MCLK1,
    o => iclk);

  ----- Normal clock(66.66MHz)
  Normal : if DEBUG generate
    bg0 : BUFG port map (
      i => iclk,
      o => sysclk);
  end generate;

  ----- Modified clock
  SpeedUp : if not DEBUG generate
    bg0 : BUFG port map (
      i => gsysclk,
      o => sysclk);

    bg1 : BUFG port map (
      i => fbclk,
      o => bfbclk);

    dcm : DCM_BASE
      generic map (
        CLKFX_MULTIPLY => 3, -- M
        CLKFX_DIVIDE => 2)   -- D
      port map (
        CLKIN => iclk,
        CLKFB => bfbclk,
        RST => '0',
        CLK0 => fbclk,
        CLK90 => open,
        CLK180 => open,
        CLK270 => open,
        CLK2X => open, -- gsysclk, -- 133MHz
        CLK2X180 => open,
        CLKDV => open,
        CLKFX => gsysclk, -- 66.6 * M / D MHz
        CLKFX180 => open,
        LOCKED => open);
  end generate;

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

  main_unit : Main port map (
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

end Core_arch;
