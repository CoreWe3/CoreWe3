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
  signal ram : ramtype := InitRamFromFile("/home/morihiro/2014-winter/fpu/fsqrt/fsqrt_table.txt");

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
  signal en : std_logic := '1';
  signal addr : unsigned(9 downto 0);
  signal data : unsigned(35 downto 0);
  signal state : std_logic_vector(1 downto 0) := "00";
  signal ui : unsigned(31 downto 0);
  signal uii: unsigned(31 downto 0);
  signal frac : unsigned(22 downto 0);
  signal exp : unsigned(7 downto 0);

  signal flag : unsigned(1 downto 0);
  signal zero_flag : unsigned(1 downto 0);
  signal exp_flag : unsigned(0 downto 0);
  signal flagtemp : unsigned(1 downto 0);
begin
  table : fsqrt_table port map(
    clk => clk,
    en => en,
    addr => addr,
    data => data);
  process(clk)
    variable y : unsigned(23 downto 0);
    variable d : unsigned(13 downto 0);
    variable uiv : unsigned(31 downto 0);
    variable expv : unsigned(7 downto 0);
    variable o_mant : unsigned(28 downto 0);
    variable e_mant : unsigned(27 downto 0);
    variable mant : unsigned(23 downto 0);
    variable otemp : unsigned(31 downto 0);
  begin
    if i(23) = '1' then
      addr <= unsigned("00" & i(22 downto 15));
    else
      addr <= (256 + unsigned("0" & i(22 downto 14)));
    end if;
    if rising_edge(clk) then
      case state is
        when "00" =>
          ui <= unsigned(i);
          if i(30 downto 0) = (x"0000000" & "000") then
            flag <= "00";
          elsif i(31) = '1' then
            flag <= "11";
          elsif i(23) = '1' then
            flag <= "01";
          else
            flag <= "10";
          end if;
--          if i(30 downto 23) >= 127 then
          if (i(30) = '1' or i(30 downto 23) = "01111111") then
            exp_flag <= "1";
          else
            exp_flag <= "0";
          end if;
          if i(14 downto 0) = (x"000" & "000") then
            zero_flag <= "00";
          elsif i(13 downto 0) = (x"000" & "00") then
            zero_flag <= "10";
          elsif i(22 downto 0) = ("111" & x"fffff") then
            zero_flag <= "11";
          else
            zero_flag <= "01";
          end if;
          state <= "01";
        when "01" =>
          flagtemp <= flag;
          y := "1" & (data(35 downto 13));
          d := "1" & (data(12 downto 0));
          uiv := ui;
          expv := ui(30 downto 23);
          if exp_flag = "1" then
            expv := expv - 127;
            expv := shift_right(expv,1);
            expv := expv + 127;
          else
            expv := 128 - expv;
            expv := shift_right(expv,1);
            expv := 127 - expv;
          end if;
          if flag = "01" then
            if zero_flag = "00" then
            --if zero_flag = "01" then
              mant := y - d;
              frac <= mant(22 downto 0);
            else
              o_mant := y - shift_right(d * (32768 - uiv(14 downto 0)),15);
              frac <= o_mant(22 downto 0);
            end if;
          else
            if zero_flag = "00" or zero_flag = "10" then
--            if zero_flag = "10" then
              mant := y - d;
              frac <= mant(22 downto 0);
            elsif zero_flag = "11" then
              frac <= uiv(22 downto 0);
            else
              e_mant := y - shift_right(d * (16384 - uiv(13 downto 0)),14);
              frac <= e_mant(22 downto 0);
            end if;
          end if;
          exp <= expv;
          uii <= ui;
          state <= "10";
        when "10" =>
          if flagtemp = "00" then
            otemp := uii;
          elsif flagtemp = "11" then
            otemp := x"ffc00000";
          else
            otemp := "0" & exp & frac;
          end if;
          o <= std_logic_vector(otemp);
          state <= "00";
        when others =>
          state <= "00";
      end case;
    end if;
  end process;
end blackbox;
