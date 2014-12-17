library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package util is
  constant ADDR_WIDTH : integer := 4;

  type inst_out_t is record
    d : std_logic_vector(31 downto 0);
  end record inst_out_t;

  type inst_in_t is record
    a : unsigned(ADDR_WIDTH-1 downto 0);
  end record inst_in_t;

  type mem_out_t is record
    d : unsigned(31 downto 0);
    busy : std_logic;
  end record mem_out_t;

  type mem_in_t is record
    a : unsigned(19 downto 0);
    d : unsigned(19 downto 0);
    go : std_logic;
    we : std_logic;
  end record mem_in_t;

end package util;
