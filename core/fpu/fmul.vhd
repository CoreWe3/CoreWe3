library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity fmul is
  port (
    clk : in std_logic;
    a : in  std_logic_vector(31 downto 0);
    b : in  std_logic_vector(31 downto 0);
    o : out std_logic_vector(31 downto 0));
end Fmul;


architecture pipeline of fmul is
  signal lh :std_logic_vector(23 downto 0);
  signal hl :std_logic_vector(23 downto 0);
  signal hh :std_logic_vector(25 downto 0);
  signal sign_0 : std_logic;
  signal sign_1 : std_logic;
  signal exp_0 : std_logic_vector(9 downto 0);
  signal exp_1 : std_logic_vector(9 downto 0);
  signal exp_2 : std_logic_vector(9 downto 0);
  signal frac : std_logic_vector(25 downto 0);

begin
  fmul1:process(clk)
  begin
    if rising_edge(clk) then
      --stage1
      hh <= ("1" & a(22 downto 11)) * ("1" & b(22 downto 11));
      hl <= ("1" & a(22 downto 11)) * b(10 downto 0);
      lh <= a(10 downto 0) * ("1" & b(22 downto 11));
      exp_0 <= ("00" & a(30 downto 23)) + ("00" & b(30 downto 23)) + 129;
      sign_0 <= a(31) XOR b(31);

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
          o<=sign_1 & exp_1(7 downto 0)& frac(23 downto 1);
        end if;
      else
        if exp_2(8) = '0' then
          if exp_2(8) = '0' then
            o <= sign_1 & "0000000000000000000000000000000";
          else
            o <= sign_1 & "1111111100000000000000000000000";
          end if;
        else
          o <= sign_1 & exp_2(7 downto 0)& frac(24 downto 2);
        end if;
      end if;
    end if;
  end process;

end architecture;
