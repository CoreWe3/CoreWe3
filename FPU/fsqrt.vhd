library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;

entity fsqrt_table is
  port(
    clk : in std_logic;
    en  : in std_logic;
    addr : in unsigned(9 downto 0);
    data : out unsigned(35 downto 0));
end fsqrt_table;

architecture blackbox of fsqrt_table is
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
  signal ram : ramtype := InitRamFromFile("fsqrt_table.txt");

begin
  process (CLK)
  begin
    if rising_edge(clk) then
      if en = '1' then
        data <= ram(to_integer(addr));
      end if;
    end if;
  end process;
end blackbox;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity fsqrt is
  port(
    clk : in std_logic;
    stall : in std_logic;
    i   : in std_logic_vector(31 downto 0);
    o   : out std_logic_vector(31 downto 0));
end fsqrt;

architecture blackbox of fsqrt is
  component fsqrt_table is
    port(
      clk : in std_logic;
      en  : in std_logic;
      addr : in unsigned(9 downto 0);
      data : out unsigned(35 downto 0));
  end component;
  signal addr : unsigned(9 downto 0);

  signal ui : unsigned(31 downto 0);
  signal flag1 : unsigned(1 downto 0);
  signal data : unsigned(35 downto 0);

  signal frag2 : unsigned(1 downto 0);
  signal uii: unsigned(31 downto 0);
  signal exp : unsigned(7 downto 0);
  signal const : unsigned(22 downto 0);
  signal stub : unsigned(13 downto 0);
begin

  table : fsqrt_table port map(
    clk => clk,
    en => '1',
    addr => addr,
    data => data);

  addr <= unsigned("00" & i(22 downto 15)) when i(23) = '1' else
          (unsigned("0" & i(22 downto 14))+256);

  process(clk)
    variable expv : unsigned(8 downto 0);
    variable stub_tmp : unsigned(28 downto 0);
    variable grad : unsigned(13 downto 0);
    variable frac : unsigned(22 downto 0);
  begin

    if rising_edge(clk) and stall = '0' then
      -- stage 1
      ui <= unsigned(i);
      if i(30 downto 0) = (x"0000000" & "000") then  -- i = 0
        flag1 <= "00";
      elsif i(31) = '1' then -- i < 0
        flag1 <= "11";
      elsif i(23) = '1' then -- exponent is odd
        flag1 <= "01";
      else
        flag1 <= "10"; -- exponent is even
      end if;
      -- stage 2

      flag2 <= flag1;
      const <= data(35 downto 13);
      grad := "1" & (data(12 downto 0));
      expv := ('0' & i(30 downto 23)) + 127;
      exp <= expv(8 downto 1);
      uii <= ui;

      if flag1 = "01" then
        stub_tmp := grad * (32768 - uiv(14 downto 0)); -- 14 * 15;
        stub <= stub_tmp(28 downto 15);
      else
        stub_tmp := grad * (16384 - uiv(13 downto 0)); -- 14 * 14;
        stub <= stub_tmp(27 downto 14);
      end if;

      -- stage 3

      if flag2 = "00" then -- zero
        o <= (others => '0');
      elsif flag2 = "11" then -- minus
        o <= x"ffc00000";
      elsif flag = "01" then -- odd
        frac := const - stub;
        o <= std_logic_vector('0' & exp & frac);
      else -- even
        if uii(22 downto 0) = "111" & x"fffff" then
          frac := (others => '1');
        else
          frac := const - stub;
        end if;
        o <= std_logic_vector('0' & exp & frac);
      end if;

    end if;
  end process;
end blackbox;
