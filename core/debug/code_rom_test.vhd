library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.util.all;

entity code_rom_test is
  port (
    clk : in std_logic;
    RS_TX : out std_logic);
end code_rom_test;

architecture arch of code_rom_test is
  component init_code_rom
    generic (
      CODE : string := "test.bin");
    port (
      clk   : in std_logic;
      insti : in inst_in_t;
      insto : out inst_out_t);
  end component;

  component uart_transmitter is
    generic (
      wtime : std_logic_vector(15 downto 0) := x"0001");
    port (
      clk  : in std_logic;
      data : in std_logic_vector(7 downto 0);
      go   : in std_logic;
      busy : out std_logic;
      tx   : out std_logic);
  end component;

  signal state : unsigned(2 downto 0) := (others => '0');
  signal data : std_logic_vector(7 downto 0);
  signal go : std_logic;
  signal busy : std_logic;
  signal insti : inst_in_t := (a => (others => '0'));
  signal insto : inst_out_t;
begin

  rom : init_code_rom port map (
    clk => clk,
    insti => insti,
    insto => insto);

  tranmit : uart_transmitter port map (
    clk => clk,
    data => data,
    go => go,
    busy => busy,
    tx => RS_TX);

  test : process(clk)
  begin
    if rising_edge(clk) then
      if busy = '0' and go = '0' then
        case state is
          when "000" =>
            go <= '1';
            data <= insto.d(31 downto 24);
          when "001" =>
            go <= '1';
            data <= insto.d(23 downto 16);
          when "010" =>
            go <= '1';
            data <= insto.d(15 downto 8);
          when "011" =>
            go <= '1';
            data <= insto.d(7  downto 0);
            insti.a <= insti.a+1;
          when others =>
        end case;
        state <= state+1;
      else
        go <= '0';
      end if;

    end if;
  end process;

end arch;
