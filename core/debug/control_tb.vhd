library ieee;
use ieee.std_logic_1164.all;

entity control_tb is
end control_tb;

architecture tb of control_tb is
  constant wtime : std_logic_vector(15 downto 0) := x"0007";

  component control is
    generic (
      CODE       : string                        := "file/test.bin";
      ADDR_WIDTH : integer                       := 4;
      wtime      : std_logic_vector(15 downto 0) := wtime);
    port(
      clk   : in    std_logic;
      RS_TX : out   std_logic;
      RS_RX : in    std_logic;
      ZD    : inout std_logic_vector(31 downto 0);
      ZA    : out   std_logic_vector(19 downto 0);
      XWA   : out   std_logic);
  end component;

  component SRAM is
    port (
      clk : in    std_logic;
      ZD  : inout std_logic_vector(31 downto 0);
      ZA  : in    std_logic_vector(19 downto 0);
      XWA : in    std_logic);
  end component;

  component input_simulator
    generic (
      wtime      : std_logic_vector(15 downto 0) := wtime;
      INPUT_FILE : string                        := "input.txt");
    port (
      clk   : in  std_logic;
      RS_RX : out std_logic);
  end component;

  component output_simulator
    generic (
      wtime       : std_logic_vector(15 downto 0) := wtime;
      OUTPUT_FILE : string                        := "output.txt");
    port (
      clk   : std_logic;
      RS_TX : std_logic);
  end component;

  signal clk   : std_logic := '0';
  signal RS_TX : std_logic;
  signal RS_RX : std_logic;
  signal ZD    : std_logic_vector(31 downto 0);
  signal ZA    : std_logic_vector(19 downto 0);
  signal XWA   : std_logic;

begin

  main : control port map (
    clk   => clk,
    RS_TX => RS_TX,
    RS_RX => RS_RX,
    ZD    => ZD,
    ZA    => ZA,
    XWA   => XWA);

  sram_sim : SRAM port map (
    clk => clk,
    ZD  => ZD,
    ZA  => ZA,
    XWA => XWA);

  input_sim : input_simulator port map (
    clk   => clk,
    RS_RX => RS_RX);

  output_sim : output_simulator port map (
    clk   => clk,
    RS_TX => RS_TX);

  process
  begin
    clk <= '0';
    wait for 1 ps;
    clk <= '1';
    wait for 1 ps;
  end process;

end tb;
