library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity core_main_tb is
end core_main_tb;

architecture arch_core_main_tb of core_main_tb is
  constant wtime : std_logic_vector(15 downto 0) := x"000F";
  constant CLKR : integer := 1;
  
  component core_main
    generic (
      CODE       : string := "test.tbin";
      ADDR_WIDTH : integer := 8;
      CLKR       : integer := CLKR;
      wtime      : std_logic_vector(15 downto 0) := wtime;
      debug      : boolean := false);
    port (
      sysclk : in    std_logic;
      memclk : in    std_logic;
      RS_TX  : out   std_logic;
      RS_RX  : in    std_logic;
      ZD     : inout std_logic_vector(31 downto 0);
      ZA     : out   std_logic_vector(19 downto 0);
      XWA    : out   std_logic);
  end component;

  component SRAM
    port (
      clk : in std_logic;
      ZD : inout std_logic_vector(31 downto 0);
      ZA : in std_logic_vector(19 downto 0);
      XWA : in std_logic);
  end component;

  component input_simulator
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime;
      INPUT_FILE : string := "test.bin");
    port (
      clk  : in  std_logic;
      RS_RX   : out std_logic);
  end component;

  component output_simulator
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime;
      OUTPUT_FILE : string := "output");
    port (
      clk : std_logic;
      RS_TX : std_logic);
  end component;
  
  signal sysclk : std_logic;
  signal memclk : std_logic;
  signal RS_TX  : std_logic;
  signal RS_RX  : std_logic;
  signal ZD     : std_logic_vector(31 downto 0);
  signal ZA     : std_logic_vector(19 downto 0);
  signal XWA    : std_logic;
begin

  main : core_main port map (
    sysclk => memclk,   
    memclk => memclk,   
    RS_TX  => RS_TX , 
    RS_RX  => RS_RX , 
    ZD     => ZD    , 
    ZA     => ZA    , 
    XWA    => XWA   );

  sram_sim : SRAM port map (
    clk => memclk,
    ZD  => ZD,
    ZA  => ZA,
    XWA => XWA);

  input_sim : input_simulator port map (
    clk   => memclk,
    RS_RX => RS_RX);

  output_sim : output_simulator port map (
    clk   => memclk,
    RS_TX => RS_TX);
    
  process
  begin
    sysclk <= '0';
    memclk <= '0';
    wait for 1 ns;
    sysclk <= '1';
    memclk <= '0';
    wait for 1 ns;
    sysclk <= '0';
    memclk <= '1';
    wait for 1 ns;
    sysclk <= '1';
    memclk <= '1';
    wait for 1 ns;
  end process;


end arch_core_main_tb;
