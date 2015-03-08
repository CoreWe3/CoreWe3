library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;

entity finv2 is
  port(
    clk : in std_logic;
    stall : in std_logic;
    i   : in std_logic_vector(31 downto 0);
    o   : out std_logic_vector(31 downto 0));
end finv2;

architecture finv2_arch of finv2 is

  type ramtype is array(0 to 2047) of unsigned(35 downto 0);

  impure function InitRamFromFile (RamFileName : string) return ramtype is
    file ramFile : text open read_mode is RamFileName;
    variable ramFileLine : line;
    variable ram : ramtype;
    variable temp : std_logic_vector(35 downto 0);
  begin
    for I in ramtype'range loop
      readline (ramFile, ramFileLine);
      read (ramFileLine,temp);
      ram(I) := unsigned(temp);
    end loop;
    return ram;
  end function;

  signal ram : ramtype := InitRamFromFile("finv_table.dat");
  signal isig : std_logic;
  signal iexp : unsigned(7 downto 0);
  signal ifrac : unsigned(11 downto 0);
  signal data : unsigned(35 downto 0);
  signal const : unsigned(22 downto 0);
  signal grad : unsigned(12 downto 0);
  signal osig : std_logic;
  signal oexp : unsigned(7 downto 0);
begin

  process(clk)
    variable vgrad : unsigned(24 downto 0);
    variable ofrac : unsigned(22 downto 0);
    variable result : unsigned(31 downto 0);
  begin

    if rising_edge(clk) and stall = '0' then
      isig <= i(31);
      iexp <= unsigned(i(30 downto 23));
      data <= ram(to_integer(unsigned(i(22 downto 12))));
      ifrac <= unsigned(i(11 downto 0));

      -- stage 2
      osig <= isig;
      if iexp > 253 then
        oexp <= (others => '0');
      else
        oexp <= 253-iexp;
      end if;
      const <= data(22 downto 0);
      vgrad := data(35 downto 23) * ifrac;
      grad <= vgrad(24 downto 12);

      -- stage 3
      ofrac := const - grad;
      result := osig & oexp & ofrac;
      o <= std_logic_vector(result);

    end if;
  end process;

end finv2_arch;
