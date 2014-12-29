library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity detect_hazard is
  port (
    a1 : in unsigned(5 downto 0);
    a2 : in unsigned(5 downto 0);
    dest1 : in unsigned(5 downto 0);
    dest2 : in unsigned(5 downto 0);
    data_hazard : out std_logic);
end detect_hazard;

architecture arch_detect_hazard of detect_hazard is
  signal nez1, nez2 : std_logic;
  signal dep1, dep2 : std_logic;
  signal haz1, haz2 : std_logic;
begin

  nez1 <= '1' when a1 /= 0 else '0';
  nez2 <= '1' when a2 /= 0 else '0';

  dep1 <= '1' when a1 = dest1 or a1 = dest2 else
          '0';
  dep2 <= '1' when a2 = dest1 or a2 = dest2 else
          '0';

  haz1 <= nez1 and dep1;
  haz2 <= nez2 and dep2;

  data_hazard <= haz1 or haz2;

end arch_detect_hazard;
