library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_right_round is
  port (
    d : in  unsigned(24 downto 0);
    exp_dif  : in unsigned(7 downto 0);
    o : out unsigned(27 downto 0));
end entity;

architecture arch_shift_right_round of shift_right_round is
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

end arch_shift_right_round;
