library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity fle is
  port (
    a : in std_logic_vector(31 downto 0);
    b : in std_logic_vector(31 downto 0);
    cmp : out std_logic);
end fle;

architecture arch_fle of fle is
begin

  process(a,b)
    variable signs : std_logic_vector(1 downto 0);
  begin
    signs := a(31) & b(31);
    if ((a(30 downto 23) = x"ff") and (a(22 downto 0) /= 0)) then
      cmp <= '0';
    elsif ((b(30 downto 23) = x"ff") and (b(22 downto 0) /= 0)) then
      cmp <= '0';
    else
      if (a(30 downto 0) = b(30 downto 0)) then
        case signs is
          when "00" | "10" | "11" =>
            cmp <= '1';
          when others =>
            cmp <= '0';
        end case;
      elsif (a(30 downto 0) < b(30 downto 0)) then
        case signs is
          when "00" | "10" =>
            cmp <= '1';
          when others =>
            cmp <= '0';
        end case;
      else
        case signs is
          when "11" | "10" =>
            cmp <= '1';
          when others =>
            cmp <= '0';
        end case;
      end if;
    end if;
  end process;

end arch_fle;
