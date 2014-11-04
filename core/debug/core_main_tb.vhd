library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity core_main_tb is
end core_main_tb;

architecture arch_core_main_tb of core_main_tb is
  component core_main
    generic (
      CODE : string := "stack_test.bin";
      wtime : std_logic_vector(15 downto 0) := x"000F";
      debug : boolean := true);
    port (
      clk   : in    std_logic;
      RS_TX : out   std_logic;
      RS_RX : in    std_logic;
      ZD    : inout std_logic_vector(31 downto 0);
      ZA    : out   std_logic_vector(19 downto 0);
      XWA   : out   std_logic);
  end component;

  component SRAM
    port (
      clk : in std_logic;
      ZD : inout std_logic_vector(31 downto 0);
      ZA : in std_logic_vector(19 downto 0);
      XWA : in std_logic);
  end component;


  signal clk   : std_logic; 
  signal RS_TX : std_logic; 
  signal RS_RX : std_logic; 
  signal ZD    : std_logic_vector(31 downto 0); 
  signal ZA    : std_logic_vector(19 downto 0); 
  signal XWA   : std_logic;
begin

  main : core_main port map (
    clk   => clk   , 
    RS_TX => RS_TX , 
    RS_RX => RS_RX , 
    ZD    => ZD    , 
    ZA    => ZA    , 
    XWA   => XWA   );

  sram_sim : SRAM port map (
    clk => clk,
    ZD => ZD,
    ZA => ZA,
    XWA => XWA);
    
  process
  begin
    clk <= '0';
    wait for 1 ns;
    clk <= '1';
    wait for 1 ns;
  end process;

  
end arch_core_main_tb;
