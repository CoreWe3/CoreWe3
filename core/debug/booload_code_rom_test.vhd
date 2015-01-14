library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.VComponents.all;
library work;
use work.util.all;

entity top is
  port (
    MCLK1 : in std_logic;
    RS_RX : in std_logic;
    RS_TX : out std_logic);
end entity;

architecture arch of top is
  signal iclk : std_logic;
  signal clk : std_logic;

  signal ready : std_logic;
  signal addr : unsigned(ADDR_WIDTH-1 downto 0) := (others => '1');
  signal instr : std_logic_vector(31 downto 0);
  signal go : std_logic := '0';
  signal busy : std_logic;

begin

  ib : IBUFG port map (
    i => MCLK1,
    o => iclk);

  bg : BUFG port map (
    i => iclk,
    o => clk);

  rom : bootload_code_rom port map (
    clk => clk,
    RS_RX => RS_RX,
    ready => ready,
    addr => addr,
    instr => instr);

  transmitter : uart_transmitter port map (
    clk => clk,
    data => instr(31 downto 24),
    go => go,
    busy => busy,
    tx => RS_TX);

  process(clk)
  begin
    if rising_edge(clk) then
      if ready = '1' then
        if busy = '0' and go = '0' and addr /= 15 then
          go <= '1';
          addr <= addr+1;
        else
          go <= '0';
        end if;
      end if;
    end if;
  end process;

end arch;
