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
  begin
    if a(30 downto 0) <= b(30 downto 0) then
      case a(31 downto 31) & b(31 downto 31) is
        when "00" | "10" =>
          cmp <= '1';
        when others =>
          cmp <= '0';
      end case;
    else
      case a(31 downto 31) & b(31 downto 31) is
        when "11" | "10" =>
          cmp <= '1';
        when others =>
          cmp <= '0';
      end case;
    end if;
  end process;

end arch_fle;
        

  
    
