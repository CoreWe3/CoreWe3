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

architecture blackbox of fadd is
  signal calc : std_logic; -- '0' -> add, '1' -> sub
  signal exp_0 : unsigned(7 downto 0);
  signal big_frac : unsigned(27 downto 0);
  signal sml_frac : unsigned(27 downto 0);
  signal sign_0 : std_logic;
  signal shift_right_in : unsigned(24 downto 0);
  signal exp_dif_1 : unsigned(7 downto 0);

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
    exp_dif => exp_dif_1,
    o => sml_frac);

  process(clk)
    variable exp_dif_0 : unsigned(7 downto 0);
    variable frac_2 : unsigned(27 downto 0);
    variable frac : unsigned(22 downto 0);
    variable exp : unsigned(7 downto 0);
  begin
    if rising_edge(clk) and stall = '0' then
      -- stage1
      calc <= a(31) xor b(31);
      if unsigned(a(30 downto 0)) > unsigned(b(30 downto 0)) then
        sign_0 <= a(31);
        exp_dif_0 := unsigned(a(30 downto 23)) -
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
        exp_dif_0 := unsigned(b(30 downto 23)) -
                   unsigned(a(30 downto 23));
        exp_0 <= unsigned(b(30 downto 23));
        big_frac <= unsigned("01" & b(22 downto 0) & "000");
        if unsigned(a(30 downto 23)) /= 0 then
          shift_right_in <= unsigned("01" & a(22 downto 0));
        else
          shift_right_in <= (others => '0');
        end if;
      end if;
      exp_dif_1 <= exp_dif_0;

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
      if frac_2(4 downto 3) = "00" or frac_2(4 downto 3) = "10" or
        frac_2(4 downto 0) = "01000" then
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

end blackbox;
