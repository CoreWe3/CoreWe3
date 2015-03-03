library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SRAM is
  generic (
    WIDTH : integer := 10);
  port (
    clk : in std_logic;
    ZD : inout std_logic_vector(31 downto 0);
    ZA : in std_logic_vector(19 downto 0);
    XWA : in std_logic;
    ADVA : in std_logic);
end SRAM;

architecture arch_sram of SRAM is

  type RAM_t is array (0 to 2**WIDTH -1) of natural;
  signal RAM : RAM_t;

  signal xwa1 : std_logic := '1';
  signal xwa2 : std_logic := '1';
  signal addr1: unsigned(WIDTH-1 downto 0) := (others => '0');
  signal addr2: unsigned(WIDTH-1 downto 0) := (others => '0');
begin

  ZD <= std_logic_vector(to_unsigned(RAM(to_integer(addr2)), 32)) when xwa2 = '1' else
        (others => 'Z');

  process(clk)
    variable vzd : std_logic_vector(31 downto 0);
  begin
    if rising_edge(clk) then
      xwa1 <= XWA;
      xwa2 <= xwa1;
      if ADVA = '1' then --burst mode
        addr1 <= unsigned(addr1(WIDTH-1 downto 2)) &
                 (unsigned(addr1(1 downto 0))+1);
      else
        addr1 <= unsigned(ZA(WIDTH-1 downto 0));
      end if;
      addr2 <= addr1;
      if xwa2 = '0' then
        RAM(to_integer(addr2)) <= to_integer(unsigned(ZD));
      end if;
    end if;
  end process;

end arch_sram;
