library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package util is
  constant ADDR_WIDTH : integer := 10;
  constant wtime : std_logic_vector(15 downto 0) := x"023D";

  constant LD    : std_logic_vector(5 downto 0) := "000000";
  constant ST    : std_logic_vector(5 downto 0) := "000001";
  constant LDA   : std_logic_vector(5 downto 0) := "000010";
  constant STA   : std_logic_vector(5 downto 0) := "000011";
  constant LDIH  : std_logic_vector(5 downto 0) := "000100";
  constant LDIL  : std_logic_vector(5 downto 0) := "000101";
  constant ADD   : std_logic_vector(5 downto 0) := "000110";
  constant SUB   : std_logic_vector(5 downto 0) := "000111";
  constant FNEG  : std_logic_vector(5 downto 0) := "001000";
  constant ADDI  : std_logic_vector(5 downto 0) := "001001";
  constant A_ND  : std_logic_vector(5 downto 0) := "001010";
  constant O_R   : std_logic_vector(5 downto 0) := "001011";
  constant X_OR  : std_logic_vector(5 downto 0) := "001100";
  constant S_HL  : std_logic_vector(5 downto 0) := "001101";
  constant S_HR  : std_logic_vector(5 downto 0) := "001110";
  constant SHLI  : std_logic_vector(5 downto 0) := "001111";
  constant SHRI  : std_logic_vector(5 downto 0) := "010000";
  constant BEQ   : std_logic_vector(5 downto 0) := "010001";
  constant BLE   : std_logic_vector(5 downto 0) := "010010";
  constant BLT   : std_logic_vector(5 downto 0) := "010011";
  constant BFLE  : std_logic_vector(5 downto 0) := "010100";
  constant JSUB  : std_logic_vector(5 downto 0) := "010101";
  constant RET   : std_logic_vector(5 downto 0) := "010110";
  constant PUSH  : std_logic_vector(5 downto 0) := "010111";
  constant POP   : std_logic_vector(5 downto 0) := "011000";
  constant F_ADD : std_logic_vector(5 downto 0) := "011001";
  constant F_MUL : std_logic_vector(5 downto 0) := "011010";

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
    ctrl : unsigned(2 downto 0);
  end record alu_in_t;

  constant default_alu : alu_in_t := (
    d1 => (others => '-'),
    d2 => (others => '-'),
    ctrl => (others => '-'));

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


  type fetch_t is record
    pc    : unsigned(ADDR_WIDTH-1 downto 0);
  end record fetch_t;

  constant default_f :fetch_t :=
    (pc => (others => '0'));

  type decode_t is record
    pc    : unsigned(ADDR_WIDTH-1 downto 0);
    op    : std_logic_vector(5 downto 0);
    a1    : unsigned(5 downto 0);
    a2    : unsigned(5 downto 0);
    dest  : unsigned(5 downto 0);
    data   : unsigned(31 downto 0);
  end record decode_t;

  constant default_d : decode_t := (
    pc => (others => '-'),
    op => ADDI,
    a1 => (others => '0'),
    a2 => (others => '0'),
    dest => (others => '0'),
    data => (others => '-'));

  type execute_t is record
    op     : std_logic_vector(5 downto 0);
    pc     : unsigned(ADDR_WIDTH-1 downto 0);
    dest   : unsigned(5 downto 0);
    data   : unsigned(31 downto 0);
    branch : std_logic;
    alu    : alu_in_t;
    fpu    : fpu_in_t;
  end record execute_t;

  constant default_e : execute_t := (
    op => ADDI,
    pc => (others => '-'),
    dest => (others => '0'),
    data => (others => '-'),
    branch => '0',
    alu => default_alu,
    fpu => default_fpu_in);

  type memory_access_t is record
    op     : std_logic_vector(5 downto 0);
    dest   : unsigned(5 downto 0);
    data   : unsigned(31 downto 0);
    comp   : std_logic;
  end record memory_access_t;

  constant default_m : memory_access_t := (
    op => ADDI,
    dest => (others => '0'),
    data => (others => '-'),
    comp => '-');


  type cpu_t is record
    state : std_logic;
    f : fetch_t;
    d : decode_t;
    e : execute_t;
    m : memory_access_t;
    sp : unsigned(19 downto 0);
    reg: reg_in_t;
    mem: mem_in_t;
  end record cpu_t;

  constant init_r : cpu_t := (
    state => '0',
    f => default_f,
    d => default_d,
    e => default_e,
    m => default_m,
    sp => x"FFFFE",
    reg => default_reg_in,
    mem => default_mem_in);

  component core_main is
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime);
    port (
      clk   : in    std_logic;
      RS_TX : out   std_logic;
      RS_RX : in    std_logic;
      ZD    : inout std_logic_vector(31 downto 0);
      ZA    : out   std_logic_vector(19 downto 0);
      XWA   : out   std_logic);
  end component;

  component init_code_rom
    port (
      inst : out std_logic_vector(31 downto 0);
      pc   : in  unsigned(ADDR_WIDTH-1 downto 0));
  end component;

  component bootload_code_rom is
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime);
    port (
      clk   : in  std_logic;
      RS_RX : in  std_logic;
      ready : out std_logic;
      pc    : in  unsigned(ADDR_WIDTH-1 downto 0);
      inst  : out std_logic_vector(31 downto 0));
  end component;

  component memory_io
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime);
    port (
      clk   : in    std_logic;
      RS_RX : in    std_logic;
      RS_TX : out   std_logic;
      ZD    : inout std_logic_vector(31 downto 0);
      ZA    : out   std_logic_vector(19 downto 0);
      XWA   : out   std_logic;
      memi  : in    mem_in_t;
      memo  : out   mem_out_t);
  end component;

  component control is
    port(
      clk   : in  std_logic;
      memo  : in  mem_out_t;
      memi  : out mem_in_t;
      ready : in  std_logic;
      inst  : in  std_logic_vector(31 downto 0);
      pc    : out unsigned(ADDR_WIDTH-1 downto 0));
  end component;

  component bram is
    port (
      clk : in std_logic;
      di : in std_logic_vector(31 downto 0);
      do : out std_logic_vector(31 downto 0);
      addr : in std_logic_vector(11 downto 0);
      we : in std_logic);
  end component;

  component FIFO is
    generic (
      WIDTH : integer := 10);
    port (
      clk : in std_logic;
      di : in std_logic_vector(7 downto 0);
      do : out std_logic_vector(7 downto 0);
      enq : in std_logic;
      deq : in std_logic;
      empty : out std_logic;
      full : out std_logic);
  end component;

  component uart_receiver is
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime);
    port (
      clk  : in  std_logic;
      rx   : in  std_logic;
      complete : out std_logic;
      data : out std_logic_vector(7 downto 0));
  end component;

  component uart_transmitter is
    generic (
      wtime: std_logic_vector(15 downto 0) := wtime);
    Port (
      clk  : in  STD_LOGIC;
      data : in  STD_LOGIC_VECTOR (7 downto 0);
      go   : in  STD_LOGIC;
      busy : out STD_LOGIC;
      tx   : out STD_LOGIC);
  end component;

  component alu
    port (
      di : in  alu_in_t;
      do : out alu_out_t);
  end component;

  component registers
    port (
      clk : in std_logic;
      di : in reg_in_t;
      do : out reg_out_t);
  end component;

  component detect_hazard is
    port (
      a1 : in unsigned(5 downto 0);
      a2 : in unsigned(5 downto 0);
      dest1 : in unsigned(5 downto 0);
      dest2 : in unsigned(5 downto 0);
      data_hazard : out std_logic);
  end component;

  component fadd is
    port (
      clk : in std_logic;
      a   : in  std_logic_vector(31 downto 0);
      b   : in  std_logic_vector(31 downto 0);
      o   : out std_logic_vector(31 downto 0));
  end component;

  component fmul is
    port (
      clk : in std_logic;
      a : in  std_logic_vector(31 downto 0);
      b : in  std_logic_vector(31 downto 0);
      o : out std_logic_vector(31 downto 0));
  end component;

  component leading_zero_counter is
    port (
      data : in unsigned(27 downto 0);
      n : out unsigned(4 downto 0));
  end component;

  component shift_right_round is
    port (
      d : in  unsigned(24 downto 0);
      exp_dif  : in unsigned(7 downto 0);
      o : out unsigned(27 downto 0));
  end component;

end package util;
