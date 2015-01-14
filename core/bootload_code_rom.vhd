library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;
library work;
use work.util.all;

entity bootload_code_rom is
  generic(
    wtime : std_logic_vector(15 downto 0) := x"1ADB");
  port (
    clk   : in  std_logic;
    RS_RX : in  std_logic;
    ready : out std_logic;
    pc    : in  unsigned(ADDR_WIDTH-1 downto 0);
    inst  : out std_logic_vector(31 downto 0));
end bootload_code_rom;

architecture arch_code_rom of bootload_code_rom is
  constant SIZE : integer := 2 ** ADDR_WIDTH;

  type rom_t is array (0 to SIZE-1) of std_logic_vector(31 downto 0);

  signal ROM      : rom_t;
  signal state    : std_logic_vector(3 downto 0)  := x"0";
  signal complete : std_logic;
  signal data     : std_logic_vector(7 downto 0);
  signal buf      : std_logic_vector(31 downto 0);
  signal in_addr  : unsigned(ADDR_WIDTH-1 downto 0)
    := (others => '0');

  -- attribute rom_style : string;
  -- attribute rom_style of ROM : signal is "block";
begin

  recieve : uart_receiver port map (
    clk => clk,
    rx => RS_RX,
    complete => complete,
    data => data);

  process(clk)
  begin
    if rising_edge(clk) then
      case state is
        when x"0" =>
          if complete = '1' then
            buf(7 downto 0) <= data;
            state <= x"1";
          end if;
        when x"1" =>
          if complete = '1' then
            buf(15 downto 8) <= data;
            state <= x"2";
          end if;
        when x"2" =>
          if complete = '1' then
            buf(23 downto 16) <= data;
            state <= x"3";
          end if;
        when x"3" =>
          if complete = '1' then
            buf(31 downto 24) <= data;
            state <= x"4";
          end if;
        when x"4" =>
          ROM(to_integer(in_addr)) <= buf;
          if buf = x"FFFFFFFF" then --end of code
            state <= x"5";
          else
            in_addr <= in_addr+1;
            state <= x"0";
          end if;
        when others =>
          state <= x"5";
      end case;
    end if;
  end process;

  inst <= ROM(to_integer(pc));
  ready <= '1' when state = x"5" else
           '0';

end arch_code_rom;
