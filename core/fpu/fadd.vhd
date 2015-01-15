library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;
use ieee.STD_LOGIC_UNSIGNED.all;

entity fadd is
  port (
    clk : in  std_logic;
    a   : in  std_logic_vector(31 downto 0);
    b   : in  std_logic_vector(31 downto 0);
    o : out std_logic_vector(31 downto 0));
end fadd;

architecture blackbox of fadd is
  signal infa,infb : std_logic;           -- infとなる場合
  signal nana,nanb : std_logic;         -- nanとなる場合
  signal naninf : std_logic_vector(31 downto 0);            -- nan,infとなるとき
  signal hiseiki : std_logic_vector(31 downto 0);  -- 非正規化となるとき

  signal big : std_logic_vector(31 downto 0);  -- aとbの大きいほう
  signal small : std_logic_vector(31 downto 0);  -- aとbの小さい方


  signal ma : std_logic_vector(26 downto 0);  --ma+mbの桁溢れにそなえて１bit大きくする
  signal mb : std_logic_vector(26 downto 0);

  signal mc : std_logic_vector(26 downto 0);  --mbをmaの方に桁合わせしたあとのmb

  signal plus : std_logic_vector(26 downto 0);
  signal minus : std_logic_vector(26 downto 0);

  signal temp : std_logic_vector(9 downto 0);
  signal ea : std_logic_vector(9 downto 0);
  signal md : std_logic_vector(26 downto 0);

  signal atemp : std_logic_vector(31 downto 0);
  signal btemp : std_logic_vector(31 downto 0);
  signal naninftemp : std_logic_vector(31 downto 0);            -- nan,infとなるとき
  signal hiseikitemp : std_logic_vector(31 downto 0);  -- 非正規化となるとき
  signal bigtemp : std_logic_vector(31 downto 0);  -- aとbの大きいほう
  signal smalltemp : std_logic_vector(31 downto 0);  -- aとbの小さい方
  signal plustemp : std_logic_vector(26 downto 0);
  signal minustemp : std_logic_vector(26 downto 0);

begin  -- blackbox
  infa <= '1' when a(30 downto 23) = x"ff" and or_reduce(a(22 downto 0)) = '0' else '0';
  infb <= '1' when b(30 downto 23) = x"ff" and or_reduce(b(22 downto 0)) = '0' else '0';
  nana <= '1' when a(30 downto 23) = x"ff" and or_reduce(a(22 downto 0)) = '1' else '0';
  nanb <= '1' when b(30 downto 23) = x"ff" and or_reduce(b(22 downto 0)) = '1' else '0';
  naninf <= a when nana = '1' else
            b when nanb = '1' else
            a when (infa = '1' and infb = '1' and a(31)=b(31)) else
            x"7fc00000" when (infa = '1' and infb = '1') else
            a when infa='1' else
            b;                          --(inf or nan)

  hiseiki <= b when a(30 downto 23) = x"00" else
             a when b(30 downto 23) = x"00" else
             x"00000000";                         --a(30 kara 23) mo 0 b mo 0

  big <= b when a(30 downto 0) = b(30 downto 0) and a(31) = '1' else
         b when a(30 downto 0) < b(30 downto 0) else
         a;
  small <= a when a(30 downto 0) = b(30 downto 0) and a(31) = '1' else
           a when a(30 downto 0) < b(30 downto 0) else
           b;
  ma <=  "01" & big(22 downto 0) & "00";
  mb <=  "01" & small(22 downto 0) & "00";

  mc <= mb when big(30 downto 23) - small(30 downto 23) = 0 else
        "0" & mb(26 downto 1) when big(30 downto 23) - small(30 downto 23) = 1 else
        "00" & mb(26 downto 2) when big(30 downto 23) - small(30 downto 23) = 2 else
        "000" & mb(26 downto 3) when big(30 downto 23) - small(30 downto 23) = 3 else
        "0000" & mb(26 downto 4) when big(30 downto 23) - small(30 downto 23) = 4 else
        "00000" & mb(26 downto 5) when big(30 downto 23) - small(30 downto 23) = 5 else
        "000000" & mb(26 downto 6) when big(30 downto 23) - small(30 downto 23) = 6 else
        "0000000" & mb(26 downto 7) when big(30 downto 23) - small(30 downto 23) = 7 else
        "00000000" & mb(26 downto 8) when big(30 downto 23) - small(30 downto 23) = 8 else
        "000000000" & mb(26 downto 9) when big(30 downto 23) - small(30 downto 23) = 9 else
        "0000000000" & mb(26 downto 10) when big(30 downto 23) - small(30 downto 23) = 10 else
        "00000000000" & mb(26 downto 11) when big(30 downto 23) - small(30 downto 23) = 11 else
        "000000000000" & mb(26 downto 12) when big(30 downto 23) - small(30 downto 23) = 12 else
        "0000000000000" & mb(26 downto 13) when big(30 downto 23) - small(30 downto 23) = 13 else
        "00000000000000" & mb(26 downto 14) when big(30 downto 23) - small(30 downto 23) = 14 else
        "000000000000000" & mb(26 downto 15) when big(30 downto 23) - small(30 downto 23) = 15 else
        "0000000000000000" & mb(26 downto 16) when big(30 downto 23) - small(30 downto 23) = 16 else
        "00000000000000000" & mb(26 downto 17) when big(30 downto 23) - small(30 downto 23) = 17 else
        "000000000000000000" & mb(26 downto 18) when big(30 downto 23) - small(30 downto 23) = 18 else
        "0000000000000000000" & mb(26 downto 19) when big(30 downto 23) - small(30 downto 23) = 19 else
        "00000000000000000000" & mb(26 downto 20) when big(30 downto 23) - small(30 downto 23) = 20 else
        "000000000000000000000" & mb(26 downto 21) when big(30 downto 23) - small(30 downto 23) = 21 else
        "0000000000000000000000" & mb(26 downto 22) when big(30 downto 23) - small(30 downto 23) = 22 else
        "00000000000000000000000" & mb(26 downto 23) when big(30 downto 23) - small(30 downto 23) = 23 else
        "000000000000000000000000" & mb(26 downto 24) when big(30 downto 23) - small(30 downto 23) = 24 else
        "0000000000000000000000000" & mb(26 downto 25) when big(30 downto 23) - small(30 downto 23) = 25 else
        "000" & x"000000";
  plustemp <= ma + mc;
  minustemp <= ma - mc;

  fadd_pipe : process(clk)
    begin
      if rising_edge(clk) then
        atemp <= a;
        btemp <= b;
        plus <= plustemp;
        minus <= minustemp;
        naninftemp <= naninf;
        hiseikitemp <= hiseiki;
        bigtemp <= big;
        smalltemp <= small;
      end if;
    end process;

  temp <= "00" & bigtemp(30 downto 23);

  ea <= temp + 1 when bigtemp(31) = smalltemp(31) and plus(26) = '1' else
        temp when bigtemp(31) = smalltemp(31) else
        temp when minus(25) = '1' else
        temp-1 when minus(24) = '1' else
        temp-2 when minus(23) = '1' else
        temp-3 when minus(22) = '1' else
        temp-4 when minus(21) = '1' else
        temp-5 when minus(20) = '1' else
        temp-6 when minus(19) = '1' else
        temp-7 when minus(18) = '1' else
        temp-8 when minus(17) = '1' else
        temp-9 when minus(16) = '1' else
        temp-10 when minus(15) = '1' else
        temp-11 when minus(14) = '1' else
        temp-12 when minus(13) = '1' else
        temp-13 when minus(12) = '1' else
        temp-14 when minus(11) = '1' else
        temp-15 when minus(10) = '1' else
        temp-16 when minus(9) = '1' else
        temp-17 when minus(8) = '1' else
        temp-18 when minus(7) = '1' else
        temp-19 when minus(6) = '1' else
        temp-20 when minus(5) = '1' else
        temp-21 when minus(4) = '1' else
        temp-22 when minus(3) = '1' else
        temp-23 when minus(2) = '1' else
        temp-24 when minus(1) = '1' else
        temp-25 when minus(0) = '1' else
        "0000000000";
  md <= "0" & plus(26 downto 1) when bigtemp(31) = smalltemp(31) and plus(26) = '1' else
        plus when bigtemp(31) = smalltemp(31) else
        minus when  minus(25) = '1' else
        minus(25 downto 0) & "0" when minus(24)='1' else
        minus(24 downto 0) & "00" when minus(23)='1' else
        minus(23 downto 0) & "000" when minus(22)='1' else
        minus(22 downto 0) & "0000" when minus(21)='1' else
        minus(21 downto 0) & "00000" when minus(20)='1' else
        minus(20 downto 0) & "000000" when minus(19)='1' else
        minus(19 downto 0) & "0000000" when minus(18)='1' else
        minus(18 downto 0) & "00000000" when minus(17)='1' else
        minus(17 downto 0) & "000000000" when minus(16)='1' else
        minus(16 downto 0) & "0000000000" when minus(15)='1' else
        minus(15 downto 0) & "00000000000" when minus(14)='1' else
        minus(14 downto 0) & "000000000000" when minus(13)='1' else
        minus(13 downto 0) & "0000000000000" when minus(12)='1' else
        minus(12 downto 0) & "00000000000000" when minus(11)='1' else
        minus(11 downto 0) & "000000000000000" when minus(10)='1' else
        minus(10 downto 0) & "0000000000000000" when minus(9)='1' else
        minus(9 downto 0) & "00000000000000000" when minus(8)='1' else
        minus(8 downto 0) & "000000000000000000" when minus(7)='1' else
        minus(7 downto 0) & "0000000000000000000" when minus(6)='1' else
        minus(6 downto 0) & "00000000000000000000" when minus(5)='1' else
        minus(5 downto 0) & "000000000000000000000" when minus(4)='1' else
        minus(4 downto 0) & "0000000000000000000000" when minus(3)='1' else
        minus(3 downto 0) & "00000000000000000000000" when minus(2)='1' else
        minus(2 downto 0) & "000000000000000000000000" when minus(1)='1' else
        minus(1 downto 0) & "0000000000000000000000000" when minus(0)='1' else
        "000000000000000000000000000";

  o <=  naninftemp when atemp(30 downto 23) = x"ff" or btemp(30 downto 23) = x"ff" else
        hiseikitemp when atemp(30 downto 23) = x"00" or btemp(30 downto 23) = x"00" else
        x"00000000" when (bigtemp(31) /= smalltemp(31) and minus = "000" & x"000000") or ea = "0000000000" else
        bigtemp(31) & "1111111100000000000000000000000" when ea >= x"ff" else
        bigtemp(31) & ea(7 downto 0) & md(24 downto 2);

end blackbox;
