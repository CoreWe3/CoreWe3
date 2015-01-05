library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fadd is
  port (
    clk : in  std_logic;
    a   : in  std_logic_vector(31 downto 0);
    b   : in  std_logic_vector(31 downto 0);
    o : out std_logic_vector(31 downto 0));
end fadd;

architecture blackbox of fadd is
  signal calc : std_logic; -- '0' -> add, '1' -> sub
  signal exp_0 : unsigned(7 downto 0);
  signal big_frac : unsigned(24 downto 0);
  signal sml_frac : unsigned(24 downto 0);
  signal sign_0 : std_logic;

  signal frac_1 : unsigned(24 downto 0);
  signal sign_1 : std_logic;
  signal exp_1 : unsigned(7 downto 0);
  signal lead_zero : unsigned(4 downto 0);

  component leading_zero_counter is
    port (
      data : in unsigned(24 downto 0);
      n : out unsigned(4 downto 0));
  end component;

begin

  LZC : leading_zero_counter port map(
    data => frac_1,
    n => lead_zero);

  process(clk)
    variable exp_dif : unsigned(7 downto 0);
    variable frac : unsigned(24 downto 0);
    variable exp : unsigned(7 downto 0);
  begin
    if rising_edge(clk) then
      -- stage1
      calc <= a(31) xor b(31);
      if unsigned(a(30 downto 0)) > unsigned(b(30 downto 0)) then
        sign_0 <= a(31);
        exp_dif := unsigned(a(30 downto 23)) -
                   unsigned(b(30 downto 23));
        exp_0 <= unsigned(a(30 downto 23));
        big_frac <= unsigned("01" & a(22 downto 0));
        if unsigned(b(30 downto 23)) /= 0 then
          sml_frac <= shift_right(unsigned("01" & b(22 downto 0)),
                                  to_integer(exp_dif));
        else
          sml_frac <= (others => '0');
        end if;
      else
        sign_0 <= b(31);
        exp_dif := unsigned(b(30 downto 23)) -
                   unsigned(a(30 downto 23));
        exp_0 <= unsigned(b(30 downto 23));
        big_frac <= unsigned("01" & b(22 downto 0));
        if unsigned(a(30 downto 23)) /= 0 then
          sml_frac <= shift_right(unsigned("01" & a(22 downto 0)),
                                  to_integer(exp_dif));
        else
          sml_frac <= (others => '0');
        end if;
      end if;

      -- stage2
      if calc = '0' then
        frac_1 <= big_frac + sml_frac;
      else
        frac_1 <= big_frac - sml_frac;
      end if;
      sign_1 <= sign_0;
      exp_1 <= exp_0;

      -- stage3
      if exp_1 /= 255 then
        exp := exp_1 - lead_zero + 1;
      else
        exp := exp_1;
      end if;
      frac := shift_left(frac_1, to_integer(lead_zero));
      o <= std_logic_vector(sign_1 & exp & frac(23 downto 1));
    end if;
  end process;

end blackbox;
