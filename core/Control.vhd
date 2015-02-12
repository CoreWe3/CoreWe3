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

begin
  instruction_mem_i <= r.pc;
  data_mem_i <= r.m.mem;

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
    variable inst : std_logic_vector(31 downto 0);
    variable v_d : decode_t;
    variable v_e : execute_t;
    variable v_m : memory_access_t;
    variable data_hazard : std_logic;
    variable control_hazard : std_logic;
    variable mem_stall : std_logic;
  begin

    if rising_edge(clk) then

      if r.state = "00" then
        inst := instruction_mem_o;
      else
        inst := r.inst_buf;
      end if;

      decode(r, inst, alu_o.d, data_mem_o.d, v_d, data_hazard);
      execute(r, alu_o.d, data_mem_o.d , v_e);
      memory_access(r, alu_o.d, v_m);

      mem_stall := data_mem_o.busy;
      control_hazard := r.e.branching;

      if mem_stall = '0' then
        if control_hazard = '0' then
          if data_hazard = '0' then
            r.state <= "00";
            r.pc <= r.pc+1;
          else -- data_hazard = '1'
            r.state <= "01";
            if r.state = "00" then
              r.inst_buf <= instruction_mem_o;
            end if;
          end if;
        else -- control_hazard = '1'
          r.state <= "10";
          r.pc <= alu_o.d(ADDR_WIDTH-1 downto 0);
        end if;
        --decode
        if control_hazard = '0' and r.state /= "10" then
          if data_hazard = '0' then
            r.d <= v_d;
          else
            r.d <= default_d;
          end if;
        else
          r.d <= default_d;
        end if;
        --execute
        if control_hazard = '0' then
          r.e <= v_e;
        else
          r.e <= default_e;
        end if;
        --memory
        r.m <= v_m;
        -- write
        case r.m.op is
          when LD =>
            r.gpreg(to_integer(r.m.dest)) <= data_mem_o.d;
          when ADD | SUB | ADDI | LDIH | JSUB =>
            r.gpreg(to_integer(r.m.dest)) <= r.m.data;
          when others =>
        end case;
      else -- mem_stall = '1'
        r.state <= "11";
        if r.state = "00" then
          r.inst_buf <= instruction_mem_o;
        end if;
        r.m.mem <= default_mem_in;
      end if;

    end if;

  end process;

end Control_arch;
