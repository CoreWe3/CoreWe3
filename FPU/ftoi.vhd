library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ftoi is
  port (
    clk : in std_logic;
    stall : in std_logic;
    i : in std_logic_vector(31 downto 0);
    o : out std_logic_vector(31 downto 0));
end ftoi;

architecture ftoi_arch of ftoi is
  signal sign1 : std_logic;
  signal exp : unsigned(7 downto 0);
  signal manti : unsigned(23 downto 0);
  signal flag : std_logic_vector(1 downto 0);

  signal sign2 : std_logic;
  signal n_abs : unsigned(31 downto 0);
  signal carry : std_logic;

begin

  process(clk)
    variable vexp : unsigned(7 downto 0);
    variable vmanti : unsigned(24 downto 0);
    variable result : unsigned(31 downto 0);
  begin
    if rising_edge(clk) and stall = '0' then
      -- stage1
      sign1 <= i(31);
      vexp := unsigned(i(30 downto 23));
      manti <= unsigned('1' & i(22 downto 0));
      if vexp >= 150 then
        flag <= "00";
        exp <= unsigned(i(30 downto 23))-150;
      elsif vexp < 126 then
        flag <= "01";
        exp <= (others => '-');
      else
        flag <= "10";
        exp <= 150 - unsigned(i(30 downto 23));
      end if;

      --stage2
      sign2 <= sign1;
      if flag = "00" then
        n_abs <= shift_left("00000000" & manti, to_integer(exp(3 downto 0)));
        carry <= '0';
      elsif flag = "01" then
        n_abs <= (others => '0');
        carry <= '0';
      else
        n_abs <= "00000000" & shift_right(manti, to_integer(exp(4 downto 0)));
        vmanti := shift_left("0" & manti, to_integer(24 - exp(4 downto 0)));
        if vmanti(24) = '0' and vmanti(23) = '1' and vmanti(22 downto 0) > 0 then
          carry <= '1';
        elsif vmanti(24) = '1' and vmanti(23) = '1' then
          carry <= '1';
        else
          carry <= '0';
        end if;
      end if;

      --stage3
      if carry = '1' then
        result := n_abs+1;
      else
        result := n_abs;
      end if;
      if sign2 = '1' then
        result := (not result)+1;
      end if;
      o <= std_logic_vector(result);
    end if;
  end process;
end ftoi_arch;
