library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control is
  generic (
    CODE  : string := "code.bin";
    ADDR_WIDTH : integer := 12;
    wtime : std_logic_vector(15 downto 0) := x"023D");
  port(
    clk   : in    std_logic;
    RS_TX : out   std_logic;
    RS_RX : in    std_logic;
    ZD    : inout std_logic_vector(31 downto 0);
    ZA    : out   std_logic_vector(19 downto 0);
    XWA   : out   std_logic);
end control;

architecture arch of control is
  constant zero : std_logic_vector(31 downto 0) := (others => '0');

  component init_code_rom
    generic ( CODE  : string := CODE;
              WIDTH : integer := ADDR_WIDTH);
    port (
      clk   : in  std_logic;
      en    : in  std_logic;
      addr  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      instr : out std_logic_vector(31 downto 0));
  end component;

    component alu
    port ( in_word1 : in std_logic_vector(31 downto 0);
           in_word2 : in std_logic_vector(31 downto 0);
           out_word : out std_logic_vector(31 downto 0);
           ctrl : in std_logic_vector(2 downto 0));
  end component;

  component registers
    port (
      clk : in std_logic;
      we : in std_logic;
      addr1 : in std_logic_vector(5 downto 0);
      addr2 : in std_logic_vector(5 downto 0);
      in_word : in std_logic_vector(31 downto 0);
      out_word1 : out std_logic_vector(31 downto 0);
      out_word2 : out std_logic_vector(31 downto 0));
  end component;

  component memory_io
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime);
    port (
      clk        : in    std_logic;
      RS_RX      : in    std_logic;
      RS_TX      : out   std_logic;
      ZD         : inout std_logic_vector(31 downto 0);
      ZA         : out   std_logic_vector(19 downto 0);
      XWA        : out   std_logic;
      store_data : in    std_logic_vector(31 downto 0);
      load_data  : out   std_logic_vector(31 downto 0);
      addr       : in   std_logic_vector(19 downto 0);
      we         : in   std_logic;
      go         : in    std_logic;
      busy       : out   std_logic);
  end component;

  signal pc : std_logic_vector(ADDR_WIDTH-1 downto 0)
    := zero(ADDR_WIDTH-1 downto 0);
  signal sp : std_logic_vector(19 downto 0) := x"FFFFE";

  signal instr : std_logic_vector(31 downto 0);
  signal alu_iw1 : std_logic_vector(31 downto 0) := (others => '0');
  signal alu_iw2 : std_logic_vector(31 downto 0) := (others => '0');
  signal alu_ow : std_logic_vector(31 downto 0);
  signal ctrl : std_logic_vector(2 downto 0) := (others => '0');

  signal reg_addr1 : std_logic_vector(5 downto 0):= (others => '0');
  signal reg_addr2 : std_logic_vector(5 downto 0) := (others => '0');
  signal reg_we : std_logic := '0';
  signal reg_iw : std_logic_vector(31 downto 0) := (others => '0');
  signal reg_ow1 : std_logic_vector(31 downto 0);
  signal reg_ow2 : std_logic_vector(31 downto 0);

  signal dirtyreg : std_logic_vector(17 downto 0);

  signal mem_store : std_logic_vector(31 downto 0) := (others => '0');
  signal mem_load : std_logic_vector(31 downto 0);
  signal mem_addr : std_logic_vector(19 downto 0) := (others => '0');
  signal mem_we : std_logic := '0';
  signal mem_go : std_logic := '0';
  signal mem_busy : std_logic;

  signal branch_f : std_logic;

  signal f_go : std_logic;
  signal de_go : std_logic;
  signal m_go : std_logic;
  signal w_go : std_logic;

  type f2de is record
    instr : std_logic_vector(31 downto 0);
    pc : std_logic_vector(ADDR_WIDTH-1 downto 0);
    sp : std_logic_vector(19 downto 0);
  end record;

  signal f_to_de : f2de;
  
begin

  --control
  main : process(clk)
  begin
  end process;

  --fetch
  code :  init_code_rom port map(
    clk => clk,
    en => '1',
    addr => pc,
    instr => instr);

  fetch : process(clk)
  begin
    if rising_edge(clk) then
      if f_go = '1' then
        f_to_de.instr <= instr;
        f_to_de.pc <= pc;
        f_to_de.sp <= sp;
      end if;
  end process;

  --decode and exec
  reg : registers port map (
    clk => clk,
    we => reg_we,
    addr1 => reg_addr1,
    addr2 => reg_addr2,
    in_word => reg_iw,
    out_word1 => reg_ow1,
    out_word2 => reg_ow2);

  alu0 : alu port map (
    in_word1 => alu_iw1,
    in_word2 => alu_iw2,
    out_word => alu_ow,
    ctrl => ctrl);

  dec_exec : process(f_to_de)
    case f_to_de.instr(31 downto 26) is
      when "000000" =>
        
      

  
  
