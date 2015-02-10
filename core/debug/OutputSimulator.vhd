library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity OutputSimulator is
  generic(
    wtime : std_logic_vector(15 downto 0) := x"1ADB";
    OUTPUT_FILE : string := "output");
  port (
    clk : std_logic;
    RS_TX : std_logic);
end OutputSimulator;

architecture OutputSimulator_arch of OutputSimulator is
  component UartReceiver
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime);
    port (
      clk : in std_logic;
      rx   : in  std_logic;
      complete : out std_logic;
      data : out std_logic_vector(7 downto 0));
  end component;

  type BIN is file of character;
  file FP : BIN open write_mode is OUTPUT_FILE;
  signal data : std_logic_vector(7 downto 0);
  signal complete : std_logic;

begin

  receive : UartReceiver port map (
    clk => clk,
    rx => RS_TX,
    complete => complete,
    data => data);

  process(clk)
    variable write_char : character;
  begin
    if rising_edge(clk) then
      if complete = '1' then
        write_char := character'val(conv_integer(data));
        write(FP, write_char);
      end if;
    end if;
  end process;

end OutputSimulator_arch;
