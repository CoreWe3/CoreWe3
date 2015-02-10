library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Util is
  constant ADDR_WIDTH : integer := 10;

  constant LD    : std_logic_vector(5 downto 0) := "000000";
  constant ST    : std_logic_vector(5 downto 0) := "000001";
  constant FLD   : std_logic_vector(5 downto 0) := "000010";
  constant FST   : std_logic_vector(5 downto 0) := "000011";
  constant ITOF  : std_logic_vector(5 downto 0) := "000100";
  constant FTOI  : std_logic_vector(5 downto 0) := "000101";
  constant ADD   : std_logic_vector(5 downto 0) := "000110";
  constant SUB   : std_logic_vector(5 downto 0) := "000111";
  constant ADDI  : std_logic_vector(5 downto 0) := "001000";
  constant SH_L  : std_logic_vector(5 downto 0) := "001001";
  constant SH_R  : std_logic_vector(5 downto 0) := "001010";
  constant SHLI  : std_logic_vector(5 downto 0) := "001011";
  constant SHRI  : std_logic_vector(5 downto 0) := "001100";
  constant LDIH  : std_logic_vector(5 downto 0) := "001101";
  constant F_ADD : std_logic_vector(5 downto 0) := "001110";
  constant F_SUB : std_logic_vector(5 downto 0) := "001111";
  constant F_MUL : std_logic_vector(5 downto 0) := "010000";
  constant F_INV : std_logic_vector(5 downto 0) := "010001";
  constant F_SQRT: std_logic_vector(5 downto 0) := "010010";
  constant F_ABS : std_logic_vector(5 downto 0) := "010011";
  constant FCMP  : std_logic_vector(5 downto 0) := "010100";
  constant FLDIL : std_logic_vector(5 downto 0) := "010101";
  constant FLDIH : std_logic_vector(5 downto 0) := "010110";
  constant J     : std_logic_vector(5 downto 0) := "010111";
  constant JEQ   : std_logic_vector(5 downto 0) := "011000";
  constant JLE   : std_logic_vector(5 downto 0) := "011001";
  constant JLT   : std_logic_vector(5 downto 0) := "011010";
  constant JSUB  : std_logic_vector(5 downto 0) := "011011";
  constant RET   : std_logic_vector(5 downto 0) := "011100";


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

  constant default_mem_in : mem_in_t := (
    a => (others => '-'),
    d => (others => '-'),
    go => '0',
    we => '0');

  type alu_in_t is record
    d1 : unsigned(31 downto 0);
    d2 : unsigned(31 downto 0);
    ctrl : unsigned(1 downto 0);
  end record alu_in_t;

  constant default_alu : alu_in_t := (
    d1 => (others => '0'),
    d2 => (others => '0'),
    ctrl => (others => '0'));

  type alu_out_t is record
    d : unsigned(31 downto 0);
  end record alu_out_t;

  type fpu_in_t is record
    d1 : unsigned(31 downto 0);
    d2 : unsigned(31 downto 0);
  end record fpu_in_t;

  constant default_fpu_in : fpu_in_t := (
    d1 => (others => '-'),
    d2 => (others => '-'));

  type reg_in_t is record
    we : std_logic;
    a1 : unsigned(5 downto 0);
    a2 : unsigned(5 downto 0);
    d  : unsigned(31 downto 0);
  end record reg_in_t;

  constant default_reg_in : reg_in_t := (
    we => '0',
    a1 => (others => '-'),
    a2 => (others => '-'),
    d => (others => '-'));

  type reg_out_t is record
    d1 : unsigned(31 downto 0);
    d2 : unsigned(31 downto 0);
  end record reg_out_t;

  type regfile_t is array(0 to 31) of unsigned(31 downto 0);

  constant init_regfile : regfile_t := (
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000");

  type fetch_t is record
    pc    : unsigned(ADDR_WIDTH-1 downto 0);
  end record fetch_t;

  constant default_f :fetch_t :=
    (pc => (others => '0'));

  type decode_t is record
    pc    : unsigned(ADDR_WIDTH-1 downto 0);
    op    : std_logic_vector(5 downto 0);
    a1    : unsigned(4 downto 0);
    a2    : unsigned(4 downto 0);
    dest  : unsigned(4 downto 0);
    data   : unsigned(31 downto 0);
  end record decode_t;

  constant default_d : decode_t := (
    pc => (others => '-'),
    op => ADD,
    a1 => (others => '0'),
    a2 => (others => '0'),
    dest => (others => '0'),
    data => (others => '-'));

  type execute_t is record
    op     : std_logic_vector(5 downto 0);
    pc     : unsigned(ADDR_WIDTH-1 downto 0);
    dest   : unsigned(4 downto 0);
    data   : unsigned(31 downto 0);
    branch : std_logic;
    alu    : alu_in_t;
    fpu    : fpu_in_t;
  end record execute_t;

  constant default_e : execute_t := (
    op => ADD,
    pc => (others => '-'),
    dest => (others => '0'),
    data => (others => '-'),
    branch => '0',
    alu => default_alu,
    fpu => default_fpu_in);

  type memory_access_t is record
    op     : std_logic_vector(5 downto 0);
    dest   : unsigned(4 downto 0);
    data   : unsigned(31 downto 0);
    comp   : std_logic;
  end record memory_access_t;

  constant default_m : memory_access_t := (
    op => ADD,
    dest => (others => '0'),
    data => (others => '-'),
    comp => '-');


  type cpu_t is record
    state : std_logic;
    f : fetch_t;
    d : decode_t;
    e : execute_t;
    m : memory_access_t;
    gpreg : regfile_t;
    fpreg : regfile_t;
    mem : mem_in_t;
  end record cpu_t;

  constant init_r : cpu_t := (
    state => '0',
    f => default_f,
    d => default_d,
    e => default_e,
    m => default_m,
    gpreg => init_regfile,
    fpreg => init_regfile,
    mem => default_mem_in);

end package Util;
