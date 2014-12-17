library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity control is
  generic (
    CODE  : string := "code.bin";
    ADDR_WIDTH : integer := 12;
    wtime : std_logic_vector(15 downto 0) := x"023D");
  port(
    clk : in std_logic;
    memi  : in mem_out_t;
    memo  : out mem_in_t;
    insti  : in inst_out_t;
    insto  : out inst_in_t);
end control;

architecture arch_control of control is

  component alu
    port ( di1 : in unsigned(31 downto 0);
           di2 : in unsigned(31 downto 0);
           do : out unsigned(31 downto 0);
           ctrl : in std_logic_vector(2 downto 0));
  end component;

  component registers
    port (
      clk : in std_logic;
      we : in std_logic;
      ai : in unsigned(5 downto 0);
      ao1 : in unsigned(5 downto 0);
      ao2 : in unsigned(5 downto 0);
      di : in unsigned(31 downto 0);
      do1 : out unsigned(31 downto 0);
      do2 : out unsigned(31 downto 0));
  end component;

  signal pc : unsigned(ADDR_WIDTH-1 downto 0)
    := (others => '0');
  signal sp : std_logic_vector(19 downto 0) := x"FFFFE";

  signal instr : std_logic_vector(31 downto 0);
  signal alu_di1 : unsigned(31 downto 0) := (others => '0');
  signal alu_di2 : unsigned(31 downto 0) := (others => '0');
  signal alu_do : unsigned(31 downto 0);
  signal ctrl : std_logic_vector(2 downto 0) := (others => '0');

  signal reg_ai : unsigned(5 downto 0) := (others => '0');
  signal reg_ao1 : unsigned(5 downto 0):= (others => '0');
  signal reg_ao2 : unsigned(5 downto 0) := (others => '0');
  signal reg_we : std_logic := '0';
  signal reg_di : unsigned(31 downto 0) := (others => '0');
  signal reg_do1 : unsigned(31 downto 0);
  signal reg_do2 : unsigned(31 downto 0);

  signal mem_store : std_logic_vector(31 downto 0) := (others => '0');
  signal mem_load : std_logic_vector(31 downto 0);
  signal mem_addr : std_logic_vector(19 downto 0) := (others => '0');
  signal mem_we : std_logic := '0';
  signal mem_go : std_logic := '0';
  signal mem_busy : std_logic;

  signal dest : std_logic_vector(17 downto 0) := (others => '0');

  signal dec_stall : unsigned(2 downto 0) := (others => '0');
  signal dec_instr : std_logic_vector(31 downto 0);
  signal dec_pc : unsigned(ADDR_WIDTH-1 downto 0);

  signal ex_stall : unsigned(2 downto 0) := (others => '0');
  signal ex_instr : std_logic_vector(31 downto 0);
  signal ex_imm : signed(31 downto 0);
  signal ex_pc : unsigned(ADDR_WIDTH-1 downto 0);

  signal mem_stall : unsigned(2 downto 0) := (others => '0');
  signal mem_instr : std_logic_vector(31 downto 0);
  signal mem_pc : unsigned(ADDR_WIDTH-1 downto 0);

  signal wr_stall : unsigned(2 downto 0) := (others => '0');
  signal wr_instr : std_logic_vector(31 downto 0);
  signal wr_data : std_logic_vector(31 downto 0);
  signal wr_pc: unsigned(ADDR_WIDTH-1 downto 0);

  function data_hazard(signal depend : std_logic_vector(17 downto 0);
                       signal reg : std_logic_vector(5 downto 0))
    return boolean is
  begin
    if unsigned(reg) = 0 then
      return false;
    else
      if unsigned(depend(17 downto 12)) = unsigned(reg) then
        return true;
      elsif unsigned(depend(11 downto 6)) = unsigned(reg) then
        return true;
      elsif unsigned(depend(5 downto 0)) = unsigned(reg) then
        return true;
      else
        return false;
      end if;
    end if;
  end function data_hazard;

begin

  pmem :  init_code_rom port map(
    clk => clk,
    en => '1',
    addr => std_logic_vector(pc),
    instr => instr);

  reg : registers port map (
    clk => clk,
    we => reg_we,
    ai => reg_ai,
    ao1 => reg_ao1,
    ao2 => reg_ao2,
    di => reg_di,
    do1 => reg_do1,
    do2 => reg_do2);

  alu0 : alu port map (
    di1 => alu_di1,
    di2 => alu_di2,
    do => alu_do,
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
    variable hazard : boolean;
  begin
    if rising_edge(clk) then

      -- fetch
      if dec_stall <= 1 then
        dec_instr <= instr;
        dec_pc <= pc;
        pc <= pc+1;
      elsif dec_stall = 2 then
        pc <= pc+1;
      end if;

      -- decode
      if dec_stall = 0 then
        ex_instr <= dec_instr;
        ex_pc <= dec_pc;
        case dec_instr(31 downto 26) is
          when "000110" => --add
            reg_ao1 <= unsigned(dec_instr(19 downto 14));
            reg_ao2 <= unsigned(dec_instr(13 downto 8));
            dest(17 downto 12) <= dec_instr(25 downto 20);
            hazard := data_hazard(dest, dec_instr(19 downto 14)) or
                      data_hazard(dest, dec_instr(13 downto 8));
          when "001001" => --addi
            reg_ao1 <= unsigned(dec_instr(19 downto 14));
            ex_imm <= resize(signed(dec_instr(13 downto 0)),32);
            dest(17 downto 12) <= dec_instr(25 downto 20);
            hazard := data_hazard(dest, dec_instr(19 downto 14));
          when others =>
            dest(17 downto 12) <= (others => '0');
            hazard := false;
        end case;
        if hazard then
          dec_stall <= "100";
        end if;
      else
        dec_stall <= dec_stall-1;
        dest(17 downto 12) <= (others => '0');
      end if;
      dest(11 downto 0) <= dest(17 downto 6);
      ex_stall <= dec_stall;

      -- exec
      if ex_stall = 0 then
        mem_instr <= ex_instr;
        mem_pc <= ex_pc;
        case ex_instr(31 downto 26) is
          when "000110" => --add
            ctrl <= "000";
            alu_di1 <= reg_do1;
            alu_di2 <= reg_do2;
          when "001001" => --addi
            ctrl <= "000";
            alu_di1 <= reg_do1;
            alu_di2 <= unsigned(ex_imm);
          when others =>
        end case;
      end if;
      mem_stall <= ex_stall;

      -- mem
      if mem_stall = 0 then
        wr_instr <= mem_instr;
        wr_pc <= mem_pc;
        case mem_instr(31 downto 26) is
          when "000110" => --add
            wr_data <= alu_do;
          when "001001" => --addi
            wr_data <= alu_do;
          when others =>
        end case;
      end if;
      wr_stall <= mem_stall;

      -- write
      if wr_stall = 0 then
        case wr_instr(31 downto 26) is
          when "000110" => --add
            reg_we <= '1';
            reg_iw <= wr_data;
            reg_iaddr <= wr_instr(25 downto 20);
            if dec_stall = 3 then
              pc <= wr_pc;
            end if;
          when "001001" => --addi
            reg_we <= '1';
            reg_di <= wr_data;
            reg_ai <= unsigned(wr_instr(25 downto 20));
            if dec_stall = 3 then
              pc <= wr_pc;
            end if;
          when others =>
            reg_we <= '0';
        end case;
      else
        reg_we <= '0';
      end if;

    end if;
  end process;

end arch_control;
