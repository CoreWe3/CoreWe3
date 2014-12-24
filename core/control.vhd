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

  function find_data_hazard(
    r : cpu_t;
    reg : unsigned(5 downto 0))
    return boolean is
  begin
    if reg = 0 then
      return false;
    elsif r.e.dest = reg then
      return true;
    elsif r.m.dest = reg then
      return true;
    else
      return false;
    end if;
  end function find_data_hazard;

  signal r : cpu_t := init_r;
  signal nextr : cpu_t;
  signal alu_o : alu_out_t;
  signal reg_o : reg_out_t;

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
    variable vmemi : mem_in_t := default_mem_in;
    variable data_hazard : boolean;
    variable branch_hazard : boolean;
  begin
    v := r;

    --fetch
    v.f.pc := r.f.pc+1;

    --decode(detect hazard)
    v.d.pc := r.f.pc;
    v.d.op := inst(31 downto 26);
    case v.d.op is
      when ST =>
        v.d.dest := (others => '0');
        v.d.data := unsigned(resize(signed(inst(13 downto 0)), 32));
        v.d.reg.a1 := unsigned(inst(25 downto 20));
        v.d.reg.a2 := unsigned(inst(19 downto 14));
        data_hazard := find_data_hazard(r, v.d.reg.a1) or
                       find_data_hazard(r, v.d.reg.a2);
      when ADD =>
        v.d.dest := unsigned(inst(25 downto 20));
        v.d.data := (others => '0');
        v.d.reg.a1 := unsigned(inst(19 downto 14));
        v.d.reg.a2 := unsigned(inst(13 downto 8));
        data_hazard := find_data_hazard(r, v.d.reg.a1) or
                       find_data_hazard(r, v.d.reg.a2);
      when ADDI =>
        v.d.dest := unsigned(inst(25 downto 20));
        v.d.data := unsigned(resize(signed(inst(13 downto 0)), 32));
        v.d.reg.a1 := unsigned(inst(19 downto 14));
        v.d.reg.a2 := (others => '0');
        data_hazard := find_data_hazard(r, v.d.reg.a1);
      when BEQ =>
        v.d.dest := (others => '0');
        v.d.data := unsigned(resize(signed(inst(13 downto 0)), 32));
        v.d.reg.a1 := unsigned(inst(25 downto 20));
        v.d.reg.a2 := unsigned(inst(19 downto 14));
        data_hazard := find_data_hazard(r, v.d.reg.a1) or
                       find_data_hazard(r, v.d.reg.a2);
      when others =>
        data_hazard := false;
    end case;

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
      when others => null;
    end case;

    --memory access
    v.m.op := r.e.op;
    v.m.dest := r.e.dest;

    v.mem := default_mem_in;
    case r.e.op is
      when ST =>
        v.mem.a := alu_o.d(19 downto 0);
        v.mem.d := v.e.data;
        v.mem.go := '1';
        v.mem.we := '1';
      when ADD =>
        v.m.data := alu_o.d;
      when ADDI =>
        v.m.data := alu_o.d;
      when BEQ =>
        v.m.data := alu_o.d;
      when others =>
        null;
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

    -- stall
    -- resolve data hazard
    if data_hazard then
      v.f := r.f;
      v.stall.d := '1';
    else
      v.stall.d := '0';
    end if;

    if r.stall.d = '1' then
      v.d := r.d;
      v.e := default_e;
    end if;

    v.stall.e := r.stall.d;
    if r.stall.e = '1' then
      v.m := default_m;
    end if;

    v.stall.m := r.stall.e;
    if r.stall.m = '1' then
      v.w := default_w;
    end if;
    
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
      r <= nextr;
      pc <= nextr.f.pc;
      memi <= nextr.mem;
    end if;
  end process;

end arch_control;
