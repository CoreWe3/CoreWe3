library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;

entity finv is
  port(
    clk : in std_logic;
    stall : in std_logic;
    i   : in std_logic_vector(31 downto 0);
    o   : out std_logic_vector(31 downto 0));
end finv;

architecture finv_arch of finv is

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

  signal ram : ramtype := InitRamFromFile("finv_table2048.txt");
  signal data : unsigned(35 downto 0);
  signal index : unsigned(10 downto 0);
  signal ihigh : unsigned(31 downto 23);
  signal manti_const : unsigned(22 downto 0);
  signal manti_grad : unsigned(12 downto 0);
  signal stub : unsigned(11 downto 0);
  signal sign : std_logic;
  signal exp : unsigned(7 downto 0);
  signal flag : std_logic_vector(1 downto 0);
begin

  data <= ram(to_integer(index));

  process(clk)
    variable d : unsigned(12 downto 0);
    variable frac : unsigned(22 downto 0);
    variable grad_tmp : unsigned(24 downto 0);
    variable result : unsigned(31 downto 0);
  begin

    if rising_edge(clk) and stall = '0' then
      -- stage 1
      if i(22 downto 0) = (x"00000" & "000") then -- fraction is 0
        flag <= "00";
      elsif i(11 downto 0) = x"000" then -- low order 12 bits are 0
        flag <= "01";
      else
        flag <= "10";
      end if;
      index <= unsigned(i(22 downto 12));
      ihigh <= unsigned(i(31 downto 23));
      stub <= 4096 - unsigned(i(11 downto 0));

      -- stage 2
      sign <= ihigh(31);
      manti_const <= data(35 downto 13); -- constant
      d := data(12 downto 0); -- gradient
      if flag = "00" then
        exp <= 254 - ihigh(30 downto 23);
        manti_grad <= d;
      elsif flag = "01" then
        exp <= 253 - ihigh(30 downto 23);
        manti_grad <= d;
      else
        exp <= 253 - ihigh(30 downto 23);
        grad_tmp := d * stub;
        manti_grad <= grad_tmp(24 downto 12);
      end if;

      -- stage 3
      frac := manti_const + manti_grad;
      result := sign & exp & frac;
      o <= std_logic_vector(result);

    end if;
  end process;

end finv_arch;
