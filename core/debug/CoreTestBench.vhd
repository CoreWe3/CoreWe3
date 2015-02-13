library ieee;
use ieee.std_logic_1164.all;

entity CoreTestBench is
end CoreTestBench;

architecture CoreTestBench_arch of CoreTestBench is
  constant wtime : std_logic_vector(15 downto 0) := x"0008";

  component Core is
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime);
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
  end component;

  component SRAM
    generic (
      WIDTH : integer := 10);
    port (
      clk : in std_logic;
      ZD : inout std_logic_vector(31 downto 0);
      ZA : in std_logic_vector(19 downto 0);
      XWA : in std_logic);
  end component;

  component InputSimulator
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime;
      INPUT_FILE : string := "fib_loop");
    port (
      clk  : in  std_logic;
      RS_RX   : out std_logic);
  end component;

  component OutputSimulator
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime;
      OUTPUT_FILE : string := "output");
    port (
      clk : std_logic;
      RS_TX : std_logic);
  end component;

  signal clk   : std_logic := '0';
  signal RS_TX : std_logic;
  signal RS_RX : std_logic;
  signal ZD    : std_logic_vector(31 downto 0);
  signal ZA    : std_logic_vector(19 downto 0);
  signal XWA   : std_logic;
begin

  core_unit : Core port map (
    MCLK1  => clk  ,
    RS_TX  => RS_TX,
    RS_RX  => RS_RX,
    ZD     => ZD   ,
    ZA     => ZA   ,
    XE1    => open ,
    E2A    => open ,
    XE3    => open ,
    XZBE   => open ,
    XGA    => open ,
    XWA    => XWA  ,
    XZCKE  => open ,
    ZCLKMA => open ,
    ADVA   => open ,
    XFT    => open ,
    XLBO   => open ,
    ZZA    => open );

  sram_unit : SRAM port map (
    clk => clk,
    ZD  => ZD ,
    ZA  => ZA ,
    XWA => XWA);

  input_unit : InputSimulator port map (
    clk => clk,
    RS_RX => RS_RX);

  output_unit : OutputSimulator port map (
    clk => clk,
    RS_TX => RS_TX);

  process
  begin
    clk <= '0';
    wait for 1 ns;
    clk <= '1';
    wait for 1 ns;
  end process;

end CoreTestBench_arch;
