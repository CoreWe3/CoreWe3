library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fcmp is
  port (
    clk : in std_logic;
    stall : in std_logic;
    a : in std_logic_vector(31 downto 0);
    b : in std_logic_vector(31 downto 0);
    o : out std_logic_vector(31 downto 0));
end fcmp;

architecture fcmp_arch of fcmp is
begin

  process(clk)
  begin
    if rising_edge(clk) and stall = '0' then
      if signed(a(30 downto 23)) = 0 and signed(b(30 downto 23)) = 0 then
        o <= (others => '0');
      elsif signed(a) = signed(b) then
        o <= (others => '0');
      elsif signed(a) > signed(b) then
        if a(31) = '1' and b(31) = '1' then
          o <= (others => '1');
        else
          o <= x"00000001";
        end if;
      else
        if a(31) = '1' and b(31) = '1' then
          o <= x"00000001";
        else
          o <= (others => '1');
        end if;
      end if;
    end if;
  end process;
end fcmp_arch;
