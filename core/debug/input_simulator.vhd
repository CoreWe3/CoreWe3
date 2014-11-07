library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity input_simulator is
  generic (wtime : std_logic_vector(15 downto 0) := x"1ADB";
           INPUT_FILE  : string := "input");
  port( clk : in std_logic;
        RS_RX : out std_logic);
end input_simulator;

architecture sim_arch of input_simulator is
  component uart_transmitter is
    generic(wtime : std_logic_vector(15 downto 0) := wtime);
    port (
      clk  : in  std_logic;
      data : in  std_logic_vector(7 downto 0);
      go   : in  std_logic;
      busy : out std_logic;
      tx   : out std_logic);
  end component;

  type BIN is file of character;
  file FP : BIN open read_mode is INPUT_FILE;

  signal data : std_logic_vector(7 downto 0);
  signal go : std_logic;
  signal busy : std_logic;

begin
  
  process(clk)
    variable read_char : character;
  begin
    if rising_edge(clk) then
      if busy = '0' and go = '0' and endfile(FP) = false then
        read(FP, read_char);
        data <= conv_std_logic_vector(character'pos(read_char), 8);
        go <= '1';
      else
        go <= '0';
      end if;
    end if;
  end process;

  transmit : uart_transmitter port map (
    clk => clk,
    data => data,
    go => go,
    busy => busy,
    tx => RS_RX);

end sim_arch;
    
