library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity leading_zero_counter is
  port (
    data : in unsigned(27 downto 0);
    n : out unsigned(4 downto 0));
  attribute priority_extract : string;
  attribute priority_extract of leading_zero_counter :
    entity is "force";
end leading_zero_counter;

architecture LZC_arch of leading_zero_counter is
begin
  n <= "00000" when data(27) = '1' else
       "00001" when data(26) = '1' else
       "00010" when data(25) = '1' else
       "00011" when data(24) = '1' else
       "00100" when data(23) = '1' else
       "00101" when data(22) = '1' else
       "00110" when data(21) = '1' else
       "00111" when data(20) = '1' else
       "01000" when data(19) = '1' else
       "01001" when data(18) = '1' else
       "01010" when data(17) = '1' else
       "01011" when data(16) = '1' else
       "01100" when data(15) = '1' else
       "01101" when data(14) = '1' else
       "01110" when data(13) = '1' else
       "01111" when data(12) = '1' else
       "10000" when data(11) = '1' else
       "10001" when data(10) = '1' else
       "10010" when data( 9) = '1' else
       "10011" when data( 8) = '1' else
       "10100" when data( 7) = '1' else
       "10101" when data( 6) = '1' else
       "10110" when data( 5) = '1' else
       "10111" when data( 4) = '1' else
       "11000" when data( 3) = '1' else
       "11001";
end LZC_arch;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_right_round is
  port (
    d : in  unsigned(24 downto 0);
    exp_dif  : in unsigned(7 downto 0);
    o : out unsigned(27 downto 0));
end entity;

architecture shift_right_round_arch of shift_right_round is
begin

  process(d, exp_dif)
    variable shift_r : unsigned(27 downto 0);
    variable shift_l : unsigned(27 downto 0);
  begin
    shift_r := shift_right(d & "000", to_integer(exp_dif));
    shift_l := shift_left(d & "000", to_integer(28 - exp_dif));
    if shift_l = 0 then
      o <= shift_r(27 downto 1) & "0";
    else
      o <= shift_r(27 downto 1) & "1";
    end if;
  end process;

end shift_right_round_arch;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fadd is
  port (
    clk : in  std_logic;
    stall : in std_logic;
    a   : in  std_logic_vector(31 downto 0);
    b   : in  std_logic_vector(31 downto 0);
    o : out std_logic_vector(31 downto 0));
end fadd;

architecture fadd_arch of fadd is
  signal calc : std_logic; -- '0' -> add, '1' -> sub
  signal exp_0 : unsigned(7 downto 0);
  signal big_frac : unsigned(27 downto 0);
  signal sml_frac : unsigned(27 downto 0);
  signal sign_0 : std_logic;
  signal shift_right_in : unsigned(24 downto 0);
  signal exp_dif : unsigned(7 downto 0);

  signal frac_1 : unsigned(27 downto 0);
  signal sign_1 : std_logic;
  signal exp_1 : unsigned(7 downto 0);
  signal lead_zero : unsigned(4 downto 0);

  component leading_zero_counter is
    port (
      data : in unsigned(27 downto 0);
      n : out unsigned(4 downto 0));
  end component;

  component shift_right_round is
    port (
      d : in  unsigned(24 downto 0);
      exp_dif  : in unsigned(7 downto 0);
      o : out unsigned(27 downto 0));
  end component;

begin

  LZC : leading_zero_counter port map(
    data => frac_1,
    n => lead_zero);

  SRR : shift_right_round port map(
    d => shift_right_in,
    exp_dif => exp_dif,
    o => sml_frac);

  process(clk)
    variable frac_2 : unsigned(27 downto 0);
    variable frac : unsigned(22 downto 0);
    variable exp : unsigned(7 downto 0);
  begin
    if rising_edge(clk) and stall = '0' then
      -- stage1
      calc <= a(31) xor b(31);
      if unsigned(a(30 downto 0)) > unsigned(b(30 downto 0)) then
        sign_0 <= a(31);
        exp_dif <= unsigned(a(30 downto 23)) -
                   unsigned(b(30 downto 23));
        exp_0 <= unsigned(a(30 downto 23));
        big_frac <= unsigned("01" & a(22 downto 0) & "000");
        if unsigned(b(30 downto 23)) /= 0 then
          shift_right_in <= unsigned("01" & b(22 downto 0));
        else
          shift_right_in <= (others => '0');
        end if;
      else
        sign_0 <= b(31);
        exp_dif <= unsigned(b(30 downto 23)) -
                   unsigned(a(30 downto 23));
        exp_0 <= unsigned(b(30 downto 23));
        big_frac <= unsigned("01" & b(22 downto 0) & "000");
        if unsigned(a(30 downto 23)) /= 0 then
          shift_right_in <= unsigned("01" & a(22 downto 0));
        else
          shift_right_in <= (others => '0');
        end if;
      end if;

      -- stage2
      if calc = '0' then -- the same sign (addition)
        frac_1 <= big_frac + sml_frac;
      else -- different sign (subtraction)
        frac_1 <= big_frac - sml_frac;
      end if;
      sign_1 <= sign_0;
      exp_1 <= exp_0;

      -- stage3
      if lead_zero >= 25 or exp_1+1 < lead_zero then -- underflow
        exp := (others => '0');
      elsif exp_1 /= 255 then -- normal
        exp := exp_1 - lead_zero + 1;
      else -- overflow
        exp := exp_1;
      end if;

      frac_2 := shift_left(frac_1, to_integer(lead_zero));
      if frac_2(4 downto 3) = "00" or frac_2(4 downto 0) = "01000" or
        frac_2(4 downto 3) = "10" then
        frac := frac_2(26 downto 4);
      elsif frac_2(26 downto 4) = "111" & x"fffff" then --rounding and carry
        frac := (others => '0');
        exp := exp+1;
      else
        frac := frac_2(26 downto 4) + 1; -- rounding
      end if;
      o <= std_logic_vector(sign_1 & exp & frac);
    end if;
  end process;

end fadd_arch;
