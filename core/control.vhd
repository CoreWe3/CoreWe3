library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity control is
  port(
    clk   : in std_logic;
    memo  : in mem_out_t;
    memi  : out mem_in_t;
    inst  : in std_logic_vector(31 downto 0);
    pc    : out unsigned(ADDR_WIDTH-1 downto 0));
end control;

architecture arch_control of control is

  component alu
    port (
      di : in  alu_in_t;
      do : out alu_out_t);
  end component;

  component registers
    port (
      clk : in std_logic;
      rdi : in rreg_in_t;
      wdi : in wreg_in_t;
      do : out reg_out_t);
  end component;

  function detect_data_hazard(rf : unsigned(5 downto 0),
                              v : cpu_t) return std_logic is
  begin
    if rf /= 0 then
      if rf = v.d.dest or rf = v.e.dest or
        rf = v.mem.a then
        return '1';
      else
        return '0';
      end if;
    else
      return '0';
    end if;
  end function detect_data_hazard;

  signal r : cpu_t := init_r;
  signal nextr : cpu_t;
  signal alu_o : alu_out_t;
  signal reg_o : reg_out_t;
  signal setup : unsigned(1 downto 0) := (others => '0');

begin

  reg : registers port map (
    clk => clk,
    rdi => r.d.reg,
    wdi => r.w.reg,
    do => reg_o);

  alu0 : alu port map (
    di => r.e.alu,
    do => alu_o);

  main : process(r, alu_o, reg_o, memo, inst)
    variable v : cpu_t;
    variable op, ra, rb, rc : unsigned(5 downto 0);
  begin
    v := r;

    op := unsigned(inst(31 downto 26));
    ra := unsigned(inst(25 downto 20));
    rb := unsigned(inst(19 downto 14));
    rc := unsigned(inst(13 downto 8));

    --detect data hazard
    case op is
      when ST =>
        v.data_hazard := detect_data_hazard(ra, v) or
                         detect_data_hazard(rb, v);
      when others =>
        v.data_hazard := '0';
    end case;

    --fetch
    if v.data_hazard = '0' then
      v.f.pc := r.f.pc+1;
    end if;

    --decode
    if r.data_hazard = '0' then
      v.d.op := inst(31 downto 26);
      case v.d.op is
        when ST =>
          v.d.dest := (others => '0');
          v.d.data := unsigned(resize(
            signed(inst(13 downto 0)), 32));
          v.d.reg.a1 := ra;
          v.d.reg.a2 := rb;
        when ADD =>
          v.d.dest := ra;
          v.d.data := (others => '0');
          v.d.reg.a1 := rb;
          v.d.reg.a2 := rc;
        when ADDI =>
          v.d.dest := ra;
          v.d.data := unsigned(resize(
            signed(inst(13 downto 0)), 32));
          v.d.reg.a1 := rb
          v.d.reg.a2 := (others => '0');
        when BEQ =>
          v.d.dest := (others => '0');
          v.d.data := unsigned(resize(
            signed(inst(13 downto 0)), 32));
          v.d.reg.a1 := ra;
          v.d.reg.a2 := rb;
        when others =>
          v.d := default_d;
      end case;
      v.d.pc := r.f.pc;
    end if;

    --execute
    v.e.op := r.d.op;
    v.e.dest := r.d.dest;
    case r.d.op is
      when ST =>
        v.e.alu.d1 := reg_o.d2;
        v.e.alu.d2 := r.d.data;
        v.e.alu.ctrl := "000";
        v.e.branch := '0';
        v.e.data := reg_o.d1;
      when ADD =>
        v.e.alu.d1 := reg_o.d1;
        v.e.alu.d2 := reg_o.d2;
        v.e.alu.ctrl := "000";
        v.e.branch := '0';
      when ADDI =>
        v.e.alu.d1 := reg_o.d1;
        v.e.alu.d2 := r.d.data;
        v.e.alu.ctrl := "000";
        v.e.branch := '0';
      when BEQ =>
        v.e.alu.d1 := resize(r.d.pc, 32);
        v.e.alu.d2 := r.d.data;
        if reg_o.d1 = reg_o.d2 then
          v.e.branch := '1';
        else
          v.e.branch := '0';
        end if;
      when others =>
        v.e := default_e;
    end case;

    --memory access
    v.m.op := r.e.op;
    v.m.dest := r.e.dest;
    v.mem := default_mem_in;
    case r.e.op is
      when ST =>
        v.mem.a := alu_o.d(19 downto 0);
        v.mem.d := r.e.data;
        v.mem.go := '1';
        v.mem.we := '1';
      when ADD =>
        v.m.data := alu_o.d;
      when ADDI =>
        v.m.data := alu_o.d;
      when BEQ =>
        v.m.data := alu_o.d;
      when others =>
        v.m := default_m;
    end case;

    -- write
    case r.m.op is
      when ADD | ADDI =>
        v.w.reg.we := '1';
        v.w.reg.a := r.m.dest;
        v.w.reg.d := r.m.data;
      when BEQ =>
        v.w.reg.we := '0';
      when others =>
        v.w.reg.we := '0';
    end case;

    --resolve branch hazard
    if v.e.branch = '1' then
      v.d := default_d;
    end if;

    if r.e.branch = '1' then
      v.f.pc := alu_o.d(ADDR_WIDTH-1 downto 0);
      v.d := default_d;
    end if;

    --wait for memory
    if r.mem.go /= '0' or memo.busy /= '0' then
      v := r;
      v.mem := default_mem_in;
    end if;

    nextr <= v;
  end process;

  update : process(clk)
  begin
    if rising_edge(clk) then
      if setup = "11" then
        r <= nextr;
        pc <= nextr.f.pc;
        memi <= nextr.mem;
      else
        r <= init_r;
        pc <= (others => '0');
        memi <= default_mem_in;
        setup <= setup+1;
      end if;
    end if;
  end process;

end arch_control;
