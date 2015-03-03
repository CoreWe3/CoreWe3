library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity leading_zero_counter32 is
  port (
    d : in unsigned(31 downto 0);
    n : out unsigned(5 downto 0));
  attribute priority_extract : string;
  attribute priority_extract of leading_zero_counter32: entity is "force";
end leading_zero_counter32;

architecture leading_zero_counter32_arch of leading_zero_counter32 is
begin

  n <= "000000" when d(31) = '1' else
       "000001" when d(30) = '1' else
       "000010" when d(29) = '1' else
       "000011" when d(28) = '1' else
       "000100" when d(27) = '1' else
       "000101" when d(26) = '1' else
       "000110" when d(25) = '1' else
       "000111" when d(24) = '1' else
       "001000" when d(23) = '1' else
       "001001" when d(22) = '1' else
       "001010" when d(21) = '1' else
       "001011" when d(20) = '1' else
       "001100" when d(19) = '1' else
       "001101" when d(18) = '1' else
       "001110" when d(17) = '1' else
       "001111" when d(16) = '1' else
       "010000" when d(15) = '1' else
       "010001" when d(14) = '1' else
       "010010" when d(13) = '1' else
       "010011" when d(12) = '1' else
       "010100" when d(11) = '1' else
       "010101" when d(10) = '1' else
       "010110" when d( 9) = '1' else
       "010111" when d( 8) = '1' else
       "011000" when d( 7) = '1' else
       "011001" when d( 6) = '1' else
       "011010" when d( 5) = '1' else
       "011011" when d( 4) = '1' else
       "011100" when d( 3) = '1' else
       "011101" when d( 2) = '1' else
       "011110" when d( 1) = '1' else
       "011111" when d( 0) = '1' else
       "100000";

end leading_zero_counter32_arch;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity itof is
  port (
    clk : in std_logic;
    stall : in std_logic;
    i : in std_logic_vector(31 downto 0);
    o : out std_logic_vector(31 downto 0));
end itof;

architecture itof_arch of itof is

  component leading_zero_counter32 is
    port(
      d : in unsigned(31 downto 0);
      n : out unsigned(5 downto 0));
  end component;

  signal sign0 : std_logic;
  signal absolute0 : unsigned(31 downto 0);
  signal lead_zero0 : unsigned(5 downto 0);

  signal sign1 : std_logic;
  signal absolute1 : unsigned(31 downto 0);
  signal lead_zero1 : unsigned(5 downto 0);
  signal full_manti : unsigned(31 downto 0);

begin

  LZC: leading_zero_counter32 port map(
    d => absolute0,
    n => lead_zero0);

  process(clk)
    variable exp: unsigned(7 downto 0);
    variable manti : unsigned(31 downto 0);
    variable frac : unsigned(22 downto 0);
    variable carry : std_logic;
  begin
    if rising_edge(clk) and stall = '0' then
      -- stage1
      sign0 <= i(31);
      if i(31) = '1' then
        absolute0 <= (not unsigned(i))+1;
      else
        absolute0 <= unsigned(i);
      end if;

      -- stage2
      sign1 <= sign0;
      lead_zero1 <= lead_zero0;
      absolute1 <= absolute0;
      full_manti <= shift_left(absolute0, to_integer(lead_zero0));

      -- stage3
      if lead_zero1 = 32 then
        exp := (others => '0');
      else
        exp := x"9e" - lead_zero1;
      end if;

      if lead_zero1 <= 8 then
        if full_manti(8) = '0' and full_manti(7) = '1' and
          full_manti(6 downto 0) > 0 then
          carry := '1';
        elsif full_manti(8) = '1' and full_manti(7) = '1' then
          carry := '1';
        else
          carry := '0';
        end if;
        manti := shift_right(absolute1, to_integer(8-lead_zero1));
        if carry = '1' then
          frac := manti(22 downto 0)+1;
          if manti(22 downto 0) = "11111111111111111111111" then
            exp := exp+1;
          end if;
        else
          frac := manti(22 downto 0);
        end if;
      else
        manti := shift_left(absolute1, to_integer(lead_zero1-8));
        frac := manti(22 downto 0);
      end if;

      o <= std_logic_vector(sign1 & exp & frac);
    end if;
  end process;
end itof_arch;
