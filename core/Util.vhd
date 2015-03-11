library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Util is
  constant ADDR_WIDTH : integer := 13;
  constant CACHE_WIDTH : integer := 8;
  constant FIFO_WIDTH : integer := 10;
  constant BOOTLOADER: string := "file/bootloader.b";
  constant ones : unsigned(31 downto 0) := (others => '1');

  constant LD    : std_logic_vector(5 downto 0) := "000000";
  constant ST    : std_logic_vector(5 downto 0) := "000001";
  constant FLD   : std_logic_vector(5 downto 0) := "000010";
  constant FST   : std_logic_vector(5 downto 0) := "000011";
  constant I_TOF : std_logic_vector(5 downto 0) := "000100";
  constant F_TOI : std_logic_vector(5 downto 0) := "000101";
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
  constant F_CMP : std_logic_vector(5 downto 0) := "010100";
  constant FLDI  : std_logic_vector(5 downto 0) := "010101";
  constant J     : std_logic_vector(5 downto 0) := "010110";
  constant JEQ   : std_logic_vector(5 downto 0) := "010111";
  constant JLE   : std_logic_vector(5 downto 0) := "011000";
  constant JLT   : std_logic_vector(5 downto 0) := "011001";
  constant JSUB  : std_logic_vector(5 downto 0) := "011010";
  constant RET   : std_logic_vector(5 downto 0) := "011011";

  constant EOF   : std_logic_vector(5 downto 0) := "111111";

  constant NOP   : std_logic_vector(31 downto 0) := ADD & "00" & x"000000";

  type memory_reply_t is record
    d : unsigned(31 downto 0);
    stall : std_logic;
  end record;

  type memory_request_t is record
    a : unsigned(19 downto 0);
    d : unsigned(31 downto 0);
    go : std_logic;
    we : std_logic;
    f : std_logic;
  end record;

  constant default_memory_request : memory_request_t := (
    a => (others => '-'),
    d => (others => '-'),
    go => '0',
    we => '0',
    f => '0');

  type bus_in_t is record
    i : std_logic_vector(31 downto 0);
    m : memory_reply_t;
  end record;

  type bus_out_t is record
    pc : unsigned(ADDR_WIDTH-1 downto 0);
    m : memory_request_t;
  end record;

  type alu_in_t is record
    d1 : unsigned(31 downto 0);
    d2 : unsigned(31 downto 0);
    ctrl : unsigned(1 downto 0);
  end record alu_in_t;

  constant default_alu : alu_in_t := (
    d1 => (others => '0'),
    d2 => (others => '0'),
    ctrl => (others => '0'));

  type fpu_in_t is record
    d1 : unsigned(31 downto 0);
    d2 : unsigned(31 downto 0);
  end record fpu_in_t;

  constant default_fpu_in : fpu_in_t := (
    d1 => (others => '-'),
    d2 => (others => '-'));

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

  type read_data_t is record
    a : unsigned(4 downto 0);  --address(register)
    d : unsigned(31 downto 0); -- data
    f : std_logic;             -- float
    h : std_logic;             -- hazard
  end record;

  constant default_read_data : read_data_t :=
    (a => (others => '0'),
     d => (others => '0'),
     f => '0',
     h => '0');


  type write_data_t is record
    a : unsigned(4 downto 0);  -- address(register)
    d : unsigned(31 downto 0); -- data
    f : std_logic;             -- float
    r : std_logic;             -- ready
  end record;

  constant default_write_data : write_data_t :=
    (a => (others => '0'),
     d => (others => '0'),
     f => '0',
     r => '0');

  type fetch_t is record
    pc : unsigned(ADDR_WIDTH-1 downto 0);
    i : std_logic_vector(31 downto 0);
  end record fetch_t;

  constant default_f : fetch_t := (
    pc => (others => '-'),
    i => NOP);

  type prediction_t is record
    pc : unsigned(ADDR_WIDTH-1 downto 0);
    op : std_logic_vector(5 downto 0);
    ra : unsigned(4 downto 0);
    rb : unsigned(4 downto 0);
    rc : unsigned(4 downto 0);
    cx : unsigned(15 downto 0);
    br : std_logic_vector(1 downto 0);
    target : unsigned(ADDR_WIDTH-1 downto 0);
  end record prediction_t;

  constant default_p : prediction_t := (
    pc => (others => '-'),
    op => ADD,
    ra => (others => '0'),
    rb => (others => '0'),
    rc => (others => '0'),
    cx => (others => '-'),
    br => "00",
    target => (others => '-'));

  type decode_t is record
    pc : unsigned(ADDR_WIDTH-1 downto 0);
    op : std_logic_vector(5 downto 0);
    d1 : read_data_t;
    d2 : read_data_t;
    dest : unsigned(4 downto 0);
    imm : unsigned(15 downto 0);
    br : std_logic_vector(1 downto 0); -- br(1) taken, br(0) branch
    target : unsigned(ADDR_WIDTH-1 downto 0);
  end record decode_t;

  constant default_d : decode_t := (
    pc => (others => '-'),
    op => ADD,
    d1 => default_read_data,
    d2 => default_read_data,
    dest => (others => '0'),
    imm => (others => '-'),
    br => "00",
    target => (others => '-'));

  type execute_t is record
    op     : std_logic_vector(5 downto 0);
    pc     : unsigned(ADDR_WIDTH-1 downto 0);
    data   : unsigned(31 downto 0);
    alu    : alu_in_t;
    fpu    : fpu_in_t;
    wd : write_data_t;
  end record execute_t;

  constant default_e : execute_t := (
    op => ADD,
    pc => (others => '-'),
    data => (others => '-'),
    alu => default_alu,
    fpu => default_fpu_in,
    wd => default_write_data);

  type memory_access_t is record
    op : std_logic_vector(5 downto 0);
    m  : memory_request_t;
    wd : write_data_t;
  end record memory_access_t;

  constant default_ma : memory_access_t := (
    op => ADD,
    m  => default_memory_request,
    wd => default_write_data);

  type memory_wait_t is record
    op : std_logic_vector(5 downto 0);
    wd : write_data_t;
  end record memory_wait_t;

  constant default_mw : memory_wait_t := (
    op => ADD,
    wd => default_write_data);

  type memory_read_t is record
    op : std_logic_vector(5 downto 0);
    wd : write_data_t;
  end record memory_read_t;

  constant default_mr : memory_read_t := (
    op => ADD,
    wd => default_write_data);

  type cpu_t is record
    state : std_logic_vector(2 downto 0);
    pc : unsigned(ADDR_WIDTH-1 downto 0);
    f : fetch_t;
    p : prediction_t;
    d : decode_t;
    e : execute_t;
    ma : memory_access_t;
    mw : memory_wait_t;
    mr : memory_read_t;
  end record cpu_t;

  constant init_r : cpu_t := (
    state => "010",
    pc => (others => '0'),
    f => default_f,
    p => default_p,
    d => default_d,
    e => default_e,
    ma => default_ma,
    mw => default_mw,
    mr => default_mr);

end package Util;

package body Util is
end package body;
