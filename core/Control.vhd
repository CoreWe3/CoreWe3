library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Util.all;

entity Control is
  port(
    clk   : in std_logic;
    data_mem_o : in mem_out_t;
    data_mem_i : out mem_in_t;
    ready : in std_logic;
    instruction_mem_o : in std_logic_vector(31 downto 0);
    instruction_mem_i : out unsigned(ADDR_WIDTH-1 downto 0));
end Control;

architecture Control_arch of Control is

  component Alu
    port (
      di : in  alu_in_t;
      do : out alu_out_t);
  end component;

  --component fadd is
  --  port (
  --    clk : in std_logic;
  --    a   : in  std_logic_vector(31 downto 0);
  --    b   : in  std_logic_vector(31 downto 0);
  --    o   : out std_logic_vector(31 downto 0));
  --end component;

  --component fmul is
  --  port (
  --    clk : in std_logic;
  --    a : in  std_logic_vector(31 downto 0);
  --    b : in  std_logic_vector(31 downto 0);
  --    o : out std_logic_vector(31 downto 0));
  --end component;


  signal r : cpu_t := init_r;
  signal alu_o : alu_out_t;
  --signal fadd_o : std_logic_vector(31 downto 0);
  --signal fmul_o : std_logic_vector(31 downto 0);
  --signal setup : unsigned(1 downto 0) := (others => '0');
  --signal data_hazard : std_logic;
  --signal branch_hazard : std_logic;

begin
  instruction_mem_i <= r.f.pc;
  data_mem_i <= r.mem;

  alu_unit : alu port map (
    di => r.e.alu,
    do => alu_o);

  --fadd0 : fadd port map (
  --  clk => clk,
  --  a => std_logic_vector(r.e.fpu.d1),
  --  b => std_logic_vector(r.e.fpu.d2),
  --  o => fadd_o);

  --fmul0 : fmul port map (
  --  clk => clk,
  --  a => std_logic_vector(r.e.fpu.d1),
  --  b => std_logic_vector(r.e.fpu.d2),
  --  o => fmul_o);

  control_unit : process(clk)
  begin
    if rising_edge(clk) then

      --fetch
      r.f.pc <= r.f.pc+1;

      --decode
      r.d.pc <= r.f.pc;
      r.d.op <= instruction_mem_o(31 downto 26);
      case instruction_mem_o(31 downto 26) is
        when LD | FLD =>
        when ST | FST =>
        when ITOF =>
        when FTOI =>
        when ADD | SUB | SH_L | SH_R | F_ADD | F_MUL =>
          r.d.dest <= unsigned(instruction_mem_o(25 downto 21));
          r.d.d1 <= r.gpreg(to_integer(unsigned(instruction_mem_o(20 downto 16))));
          r.d.d2 <= r.gpreg(to_integer(unsigned(instruction_mem_o(15 downto 11))));
          r.d.data <= (others => '-');
        when ADDI | SHLI | SHRI | LDIH | FLDIL | FLDIH =>
          r.d.dest <= unsigned(instruction_mem_o(25 downto 21));
          r.d.d1 <= r.gpreg(to_integer(unsigned(instruction_mem_o(20 downto 16))));
          r.d.d2 <= (others => '0');
          r.d.data <= unsigned(resize(
            signed(instruction_mem_o(15 downto 0)), 32));
        when F_INV | F_SQRT | F_ABS =>
        when FCMP =>
        when J | JEQ | JLE | JLT | JSUB =>
        when RET =>
        when others =>
      end case;


      --execute
      r.e.op <= r.d.op;
      r.e.dest <= r.d.dest;
      r.e.pc <= r.d.pc;
      case r.d.op is
        when LD | FLD =>
        when ST | FST =>
        when ITOF =>
        when FTOI =>
        when ADD =>
          r.e.alu.d1 <= r.d.d1;
          r.e.alu.d2 <= r.d.d2;
          r.e.alu.ctrl <= "00";
          r.e.fpu <= default_fpu_in;
          r.e.data <= (others => '-');
        when SUB =>
        when ADDI =>
          r.e.alu.d1 <= r.d.d1;
          r.e.alu.d2 <= r.d.data;
          r.e.alu.ctrl <= "00";
          r.e.fpu <= default_fpu_in;
          r.e.data <= (others => '-');
        when SH_L =>
        when SH_R =>
        when SHLI =>
        when SHRI =>
        when JSUB =>
        when RET =>
        when others =>
      end case;

      -- memory
      r.m.op <= r.e.op;
      r.m.dest <= r.e.dest;
      case r.e.op is
        when ADD | ADDI =>
          r.m.data <= alu_o.d;
        when others =>
      end case;

      -- write
      case r.m.op is
        when LD | FLD | LDIH | FTOI | ADD | SUB | ADDI |
          SH_L | SH_R | SHLI | SHRI | JSUB =>
          r.gpreg(to_integer(r.m.dest)) <= r.m.data;
        when others =>
      end case;
    end if;

  end process;

end Control_arch;
