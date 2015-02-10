library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Util.all;

entity Main is
  generic (
    wtime : std_logic_vector(15 downto 0) := x"023D");
  port (
    clk   : in    std_logic;
    RS_TX : out   std_logic;
    RS_RX : in    std_logic;
    ZD    : inout std_logic_vector(31 downto 0);
    ZA    : out   std_logic_vector(19 downto 0);
    XWA   : out   std_logic);
end Main;

architecture Main_arch of Main is

  component InitializedInstructionMemory is
    port (
      clk : in std_logic;
      instruction_mem_o : out std_logic_vector(31 downto 0);
      instruction_mem_i : in  unsigned(ADDR_WIDTH-1 downto 0));
  end component;

  --component bootload_code_rom is
  --  generic (
  --    wtime : std_logic_vector(15 downto 0) := wtime);
  --  port (
  --    clk   : in  std_logic;
  --    RS_RX : in  std_logic;
  --    ready : out std_logic;
  --    addr  : in  unsigned(ADDR_WIDTH-1 downto 0);
  --    instr : out std_logic_vector(31 downto 0));
  --end component;

  component MemoryIO is
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime);
    port (
      clk   : in    std_logic;
      RS_RX : in    std_logic;
      RS_TX : out   std_logic;
      ZD    : inout std_logic_vector(31 downto 0);
      ZA    : out   std_logic_vector(19 downto 0);
      XWA   : out   std_logic;
      data_mem_i  : in  mem_in_t;
      data_mem_o  : out mem_out_t);
  end component;

  component Control is
    port(
      clk   : in  std_logic;
      data_mem_o  : in  mem_out_t;
      data_mem_i  : out mem_in_t;
      ready : in  std_logic;
      instruction_mem_o : in  std_logic_vector(31 downto 0);
      instruction_mem_i : out unsigned(ADDR_WIDTH-1 downto 0));
  end component;

  signal imem_o  : std_logic_vector(31 downto 0);
  signal imem_i  : unsigned(ADDR_WIDTH-1 downto 0);
  signal dmem_i  : mem_in_t;
  signal dmem_o  : mem_out_t;
  signal ready : std_logic;
  signal RS_RX_init : std_logic;
  signal RS_RX_exec : std_logic;

begin

  rom_unit : InitializedInstructionMemory port map (
    clk            => clk,
    instruction_mem_o => imem_o,
    instruction_mem_i => imem_i);
  ready <= '1';

  RS_RX_init <= RS_RX when ready = '0' else
                '1';

  RS_RX_exec <= RS_RX when ready = '1' else
                '1';

  --rom : bootload_code_rom port map (
  --  clk   => clk,
  --  RS_RX => RS_RX_init,
  --  ready => ready,
  --  addr  => pc,
  --  instr => inst);

  ram_unit : MemoryIO port map (
    clk   => clk,
    RS_RX => RS_RX_exec,
    RS_TX => RS_TX,
    ZD    => ZD,
    ZA    => ZA,
    XWA   => XWA,
    data_mem_i  => dmem_i,
    data_mem_o  => dmem_o);

  contol_unit : Control port map (
    clk     => clk,
    data_mem_o  => dmem_o,
    data_mem_i  => dmem_i,
    ready   => ready,
    instruction_mem_o  => imem_o,
    instruction_mem_i  => imem_i);

end Main_arch;
