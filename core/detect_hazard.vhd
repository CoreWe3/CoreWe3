library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity detect_hazard is
  port (
    inst  : in std_logic_vector(31 downto 0);
    dest1 : in unsigned(5 downto 0);
    dest2 : in unsigned(5 downto 0);
    dest3 : in unsigned(5 downto 0);
    data_hazard : out std_logic);
end detect_hazard;

architecture arch_detect_hazard of detect_hazard is
  signal op : std_logic_vector(5 downto 0);
  signal ra, rb, rc : unsigned(5 downto 0);
  signal eqza, eqzb, eqzc : std_logic;
  signal depa, depb, depc : std_logic;
begin
  op <= inst(31 downto 26);
  ra <= unsigned(inst(25 downto 20));
  rb <= unsigned(inst(19 downto 14));
  rc <= unsigned(inst(13 downto 8));

  eqza <= '1' when ra = 0 else '0';
  eqzb <= '1' when rb = 0 else '0';
  eqzc <= '1' when rc = 0 else '0';

  depa <= '1' when ra = dest1 or ra = dest2 or ra = dest3 else
          '0';
  depb <= '1' when rb = dest1 or rb = dest2 or rb = dest3 else
          '0';
  depc <= '1' when rc = dest1 or rc = dest2 or rc = dest3 else
          '0';

  process(op, eqza, eqzb, eqzc, depa, depb, depc)
  begin
    case op is
      when ST =>
        if eqza = '0' and depa = '1' then
          data_hazard <= '1';
        elsif eqzb = '0' and depb = '1' then
          data_hazard <= '1';
        else
          data_hazard <= '0';
        end if;
      when ADD =>
        if eqzb = '0' and depb = '1' then
          data_hazard <= '1';
        elsif eqzc = '0' and depc = '1' then
          data_hazard <= '1';
        else
          data_hazard <= '0';
        end if;
      when ADDI =>
        if eqzb = '0' and depb = '1' then
          data_hazard <= '1';
        else
          data_hazard <= '0';
        end if;
      when BEQ =>
        if eqza = '0' and depa = '1' then
          data_hazard <= '1';
        elsif eqzb = '0' and depb = '1' then
          data_hazard <= '1';
        else
          data_hazard <= '0';
        end if;
      when others =>
        data_hazard <= '0';
    end case;
  end process;
end arch_detect_hazard;
