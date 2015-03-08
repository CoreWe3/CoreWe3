library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fmul is
  port (
    clk : in std_logic;
    stall : in std_logic;
    a : in  std_logic_vector(31 downto 0);
    b : in  std_logic_vector(31 downto 0);
    o : out std_logic_vector(31 downto 0));
end fmul;

architecture fmul_arch of fmul is
  signal lh : unsigned(23 downto 0);
  signal hl : unsigned(23 downto 0);
  signal hh : unsigned(25 downto 0);
  signal sign_0 : std_logic;
  signal sign_1 : std_logic;
  signal exp_0 : unsigned(9 downto 0);
  signal exp_1 : unsigned(9 downto 0);
  signal exp_2 : unsigned(9 downto 0);
  signal frac : unsigned(25 downto 0);

begin

  process(clk)
  begin
    if rising_edge(clk) and stall = '0' then
      --stage1
      hh <= unsigned("1" & a(22 downto 11)) * unsigned("1" & b(22 downto 11));
      hl <= unsigned("1" & a(22 downto 11)) * unsigned(b(10 downto 0));
      lh <= unsigned(a(10 downto 0)) * unsigned("1" & b(22 downto 11));
      exp_0 <= unsigned("00" & a(30 downto 23)) + unsigned("00" & b(30 downto 23)) + 129;
      sign_0 <= a(31) xor b(31);

      --stage2
      frac <= hh+hl(23 downto 11)+lh(23 downto 11)+2;
      exp_1 <= exp_0;
      exp_2 <= exp_0+1;
      sign_1 <= sign_0;

      --stage3
      if frac(25) = '0' then
        if exp_1(8) = '0' then
          if exp_1(9) = '0' then
            o <= sign_1 & "0000000000000000000000000000000";
          else
            o <= sign_1 & "1111111100000000000000000000000";
          end if;
        else
          o<= std_logic_vector(sign_1 & exp_1(7 downto 0)& frac(23 downto 1));
        end if;
      else
        if exp_2(8) = '0' then
          if exp_2(9) = '0' then
            o <= sign_1 & "0000000000000000000000000000000";
          else
            o <= sign_1 & "1111111100000000000000000000000";
          end if;
        else
          o <= std_logic_vector(sign_1 & exp_2(7 downto 0)& frac(24 downto 2));
        end if;
      end if;
    end if;
  end process;

end fmul_arch;
