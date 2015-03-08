library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;

entity fsqrt2 is
  port(
    clk : in std_logic;
    stall : in std_logic;
    i   : in std_logic_vector(31 downto 0);
    o   : out std_logic_vector(31 downto 0));
end fsqrt2;

architecture fsqrt2_arch of fsqrt2 is
  type ramtype is array(0 to 1023) of unsigned(35 downto 0);
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
  signal ram : ramtype := InitRamFromFile("fsqrt_table.dat");

  signal data : unsigned(35 downto 0);
  signal iexp : unsigned(7 downto 0);
  signal ifrac : unsigned(13 downto 0);

  signal oexp : unsigned(7 downto 0);
  signal const : unsigned(22 downto 0);
  signal grad : unsigned(13 downto 0);
begin

  process(clk)
    variable vexp : unsigned(8 downto 0);
    variable vgrad : unsigned(26 downto 0);
    variable ofrac : unsigned(22 downto 0);
    variable result : unsigned(31 downto 0);
  begin

    if rising_edge(clk) and stall = '0' then
      -- stage 1
      data <= ram(to_integer(unsigned(i(23 downto 14))));
      iexp <= unsigned(i(30 downto 23));
      ifrac <= unsigned(i(13 downto 0));

      -- stage 2
      if iexp = 0 then
        oexp <= (others => '0');
      else
        vexp := ('0' & iexp) + 127;
        oexp <= vexp(8 downto 1);
      end if;
      const <= data(22  downto 0);
      vgrad := data(35 downto 23) * ifrac;
      grad <= vgrad(26 downto 13);

      -- stage 3
      ofrac := grad + const;
      result := '0' & oexp & ofrac;
      o <= std_logic_vector(result);

    end if;
  end process;
end fsqrt2_arch;
