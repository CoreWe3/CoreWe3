library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package util is
  constant ADDR_WIDTH : integer := 4;

  constant ADD : std_logic_vector(5 downto 0) := "000110";
  constant ADDI : std_logic_vector(5 downto 0) := "001001";

  type mem_out_t is record
    d : unsigned(31 downto 0);
    busy : std_logic;
  end record mem_out_t;

  type mem_in_t is record
    a : unsigned(19 downto 0);
    d : unsigned(31 downto 0);
    go : std_logic;
    we : std_logic;
  end record mem_in_t;

  constant default_mem_in : mem_in_t := (a => x"00000",
                                         d => x"00000000",
                                         go => '0',
                                         we => '0');

  type alu_in_t is record
    d1 : unsigned(31 downto 0);
    d2 : unsigned(31 downto 0);
    ctrl : unsigned(2 downto 0);
  end record alu_in_t;

  type alu_out_t is record
    d : unsigned(31 downto 0);
  end record alu_out_t;

  type rreg_in_t is record
    a1 : unsigned(5 downto 0);
    a2 : unsigned(5 downto 0);
  end record rreg_in_t;

  type wreg_in_t is record
    we : std_logic;
    a  : unsigned(5 downto 0);
    d  : unsigned(31 downto 0);
  end record wreg_in_t;

  type reg_out_t is record
    d1 : unsigned(31 downto 0);
    d2 : unsigned(31 downto 0);
  end record reg_out_t;


  type fetch_t is record
    pc    : unsigned(ADDR_WIDTH-1 downto 0);
  end record fetch_t;

  type decode_t is record
    pc    : unsigned(ADDR_WIDTH-1 downto 0);
    op    : std_logic_vector(5 downto 0);
    dest  : unsigned(5 downto 0);
    data   : unsigned(31 downto 0);
    reg   : rreg_in_t;
  end record decode_t;

  type execute_t is record
    op    : std_logic_vector(5 downto 0);
    dest  : unsigned(5 downto 0);
    data  : unsigned(31 downto 0);
    alu   : alu_in_t;
  end record execute_t;

  type memory_access_t is record
    op    : std_logic_vector(5 downto 0);
    dest  : unsigned(5 downto 0);
    data  : unsigned(31 downto 0);
  end record memory_access_t;

  type write_back_t is record
    reg   : wreg_in_t;
  end record write_back_t;

  type cpu_t is record
    f : fetch_t;
    d : decode_t;
    e : execute_t;
    m : memory_access_t;
    w : write_back_t;
  end record cpu_t;

end package util;
