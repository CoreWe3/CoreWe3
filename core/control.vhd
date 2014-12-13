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
      in_addr : in std_logic_vector(5 downto 0);
      out_addr1 : in std_logic_vector(5 downto 0);
      out_addr2 : in std_logic_vector(5 downto 0);
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
    := (others => '0');
  signal sp : std_logic_vector(19 downto 0) := x"FFFFE";

  signal instr : std_logic_vector(31 downto 0);
  signal alu_iw1 : std_logic_vector(31 downto 0) := (others => '0');
  signal alu_iw2 : std_logic_vector(31 downto 0) := (others => '0');
  signal alu_ow : std_logic_vector(31 downto 0);
  signal ctrl : std_logic_vector(2 downto 0) := (others => '0');

  signal reg_iaddr : std_logic_vector(5 downto 0) := (others => '0');
  signal reg_oaddr1 : std_logic_vector(5 downto 0):= (others => '0');
  signal reg_oaddr2 : std_logic_vector(5 downto 0) := (others => '0');
  signal reg_we : std_logic := '0';
  signal reg_iw : std_logic_vector(31 downto 0) := (others => '0');
  signal reg_ow1 : std_logic_vector(31 downto 0);
  signal reg_ow2 : std_logic_vector(31 downto 0);

  signal mem_store : std_logic_vector(31 downto 0) := (others => '0');
  signal mem_load : std_logic_vector(31 downto 0);
  signal mem_addr : std_logic_vector(19 downto 0) := (others => '0');
  signal mem_we : std_logic := '0';
  signal mem_go : std_logic := '0';
  signal mem_busy : std_logic;

  signal dest : std_logic_vector(17 downto 0) := (others => '0');

  signal stall : std_logic :='0';

  signal dec_instr : std_logic_vector(31 downto 0);
  signal dec_pc : std_logic_vector(ADDR_WIDTH-1 downto 0);

  signal ex_instr : std_logic_vector(31 downto 0);
  signal ex_imm : std_logic_vector(31 downto 0);
  signal ex_pc : std_logic_vector(ADDR_WIDTH-1 downto 0);

  signal mem_instr : std_logic_vector(31 downto 0);
  signal mem_pc : std_logic_vector(ADDR_WIDTH-1 downto 0);

  signal wr_instr : std_logic_vector(31 downto 0);
  signal wr_data : std_logic_vector(31 downto 0);
  signal wr_pc: std_logic_vector(ADDR_WIDTH-1 downto 0);

begin

  pmem :  init_code_rom port map(
    clk => clk,
    en => '1',
    addr => pc,
    instr => instr);

  reg : registers port map (
    clk => clk,
    we => reg_we,
    in_addr => reg_iaddr,
    out_addr1 => reg_oaddr1,
    out_addr2 => reg_oaddr2,
    in_word => reg_iw,
    out_word1 => reg_ow1,
    out_word2 => reg_ow2);

  alu0 : alu port map (
    in_word1 => alu_iw1,
    in_word2 => alu_iw2,
    out_word => alu_ow,
    ctrl => ctrl);

  dmem : memory_io port map(
    clk        => clk,
    RS_RX      => RS_RX,
    RS_TX      => RS_TX,
    ZD         => ZD,
    ZA         => ZA,
    XWA        => XWA,
    store_data => mem_store,
    load_data  => mem_load,
    addr       => mem_addr,
    we         => mem_we,
    go         => mem_go,
    busy       => mem_busy);


  main : process(clk)
  begin
    if rising_edge(clk) then
      -- fetch
      pc <= std_logic_vector(unsigned(pc)+1);
      dec_instr <= instr;
      dec_pc <= pc;

      -- decode
      ex_instr <= dec_instr;
      ex_pc <= dec_pc;
      case dec_instr(31 downto 26) is
        when "000110" => --add
          reg_oaddr1 <= dec_instr(19 downto 14);
          reg_oaddr2 <= dec_instr(13 downto 8);
          dest(17 downto 12) <= dec_instr(25 downto 20);
        when "001001" => --addi
          reg_oaddr1 <= dec_instr(19 downto 14);
          ex_imm <= std_logic_vector(resize(signed(dec_instr(13 downto 0)),32));
          dest(17 downto 12) <= dec_instr(25 downto 20);
        when others =>
          dest(17 downto 12) <= (others => '0');
      end case;
      dest(11 downto 0) <= dest(17 downto 6);

      -- exec
      mem_instr <= ex_instr;
      mem_pc <= ex_pc;
      case ex_instr(31 downto 26) is
        when "000110" => --add
          ctrl <= "000";
          alu_iw1 <= reg_ow1;
          alu_iw2 <= reg_ow2;
        when "001001" => --addi
          ctrl <= "000";
          alu_iw1 <= reg_ow1;
          alu_iw2 <= ex_imm;
        when others =>
      end case;

      -- mem
      wr_instr <= mem_instr;
      wr_pc <= mem_pc;
      case mem_instr(31 downto 26) is
        when "000110" => --add
          wr_data <= alu_ow;
        when "001001" => --addi
          wr_data <= alu_ow;
        when others =>
      end case;

      -- write
      case wr_instr(31 downto 26) is
        when "000110" => --add
          reg_we <= '1';
          reg_iw <= wr_data;
          reg_iaddr <= wr_instr(25 downto 20);
        when "001001" => --addi
          reg_we <= '1';
          reg_iw <= wr_data;
          reg_iaddr <= wr_instr(25 downto 20);
        when others =>
          reg_we <= '0';
      end case;

    end if;
  end process;

end arch;
