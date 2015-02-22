library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Util.all;

entity Control is
  port(
    clk     : in  std_logic;
    bus_in  : in  bus_in_t;
    bus_out : out bus_out_t);
end Control;

architecture Control_arch of Control is

  component Alu
    port (
      di : in  alu_in_t;
      do : out unsigned(31 downto 0));
  end component;

  component fadd is
    port (
      clk : in std_logic;
      stall : in std_logic;
      a   : in  std_logic_vector(31 downto 0);
      b   : in  std_logic_vector(31 downto 0);
      o   : out std_logic_vector(31 downto 0));
  end component;

  component fmul is
    port (
      clk : in std_logic;
      stall : in std_logic;
      a : in  std_logic_vector(31 downto 0);
      b : in  std_logic_vector(31 downto 0);
      o : out std_logic_vector(31 downto 0));
  end component;

  signal r : cpu_t := init_r;
  signal alu_o : unsigned(31 downto 0);
  signal fadd_o : std_logic_vector(31 downto 0);
  signal fmul_o : std_logic_vector(31 downto 0);

begin
  bus_out.pc <= r.pc;
  bus_out.m <= r.ma.m;

  alu_unit : alu port map (
    di => r.e.alu,
    do => alu_o);

  fadd_unit : fadd port map (
    clk => clk,
    stall => r.e.fpu.stall,
    a => std_logic_vector(r.e.fpu.d1),
    b => std_logic_vector(r.e.fpu.d2),
    o => fadd_o);

  fmul_unit : fmul port map (
    clk => clk,
    stall => r.e.fpu.stall,
    a => std_logic_vector(r.e.fpu.d1),
    b => std_logic_vector(r.e.fpu.d2),
    o => fmul_o);

  control_unit : process(clk)
    variable inst : std_logic_vector(31 downto 0);
    variable v_d : decode_t;
    variable v_e : execute_t;
    variable v_ma : memory_access_t;
    variable v_mw : memory_wait_t;
    variable v_wd : write_data_t;
    variable data_hazard : std_logic;
    variable control_hazard : std_logic;
    variable mem_stall : std_logic;
  begin

    if rising_edge(clk) then

      if r.state = "00" then
        inst := bus_in.i;
      else
        inst := r.inst_buf;
      end if;

      memory_access(r.e, alu_o, v_ma);
      memory_wait(r.ma, v_mw);
      write_back(r.mw, bus_in.m.d, unsigned(fadd_o), unsigned(fmul_o), v_wd);

      execute(r.d, v_ma.wd, v_mw.wd, v_wd, v_e, data_hazard);
      decode(inst, r.pc, r.gpreg, r.fpreg, v_e.wd, v_ma.wd, v_mw.wd, v_wd, v_d);

      mem_stall := bus_in.m.stall;
      control_hazard := r.e.branching;

      if mem_stall = '0' then
        if control_hazard = '0' then
          if data_hazard = '0' then
            r.state <= "00";
            r.pc <= r.pc+1;
          else -- data_hazard = '1'
            r.state <= "01";
            if r.state = "00" then
              r.inst_buf <= bus_in.i;
            end if;
          end if;
        else -- control_hazard = '1'
          r.state <= "10";
          r.pc <= alu_o(11 downto 0);
        end if;
        --decode
        if control_hazard = '0' and r.state /= "10" then
          if data_hazard = '0' then
            r.d <= v_d;
          end if;
        else
          r.d <= default_d;
        end if;
        --execute
        if control_hazard = '0' and r.state /= "10" then
          if data_hazard = '0' then
            r.e <= v_e;
          else
            r.e <= default_e;
          end if;
        else
          r.e <= default_e;
        end if;
        --memory
        r.ma <= v_ma;
        r.mw <= v_mw;
        -- write
        if v_wd.f = '0' then
          r.gpreg(to_integer(v_wd.a)) <= v_wd.d;
        else
          r.fpreg(to_integer(v_wd.a)) <= v_wd.d;
        end if;

      else -- mem_stall = '1'
        r.state <= "11";
        if r.state = "00" then
          r.inst_buf <= bus_in.i;
        end if;
        r.ma.m <= default_memory_request;
      end if;

    end if;

  end process;

end Control_arch;
