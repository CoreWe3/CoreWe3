library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity control is
  generic (
    wtime : std_logic_vector(15 downto 0) := x"023D");
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
    elsif r.d.dest = reg then
      return true;
    elsif r.e.dest = reg then
      return true;
    elsif r.m.dest = reg then
      return true;
    else
      return false;
    end if;
  end function find_data_hazard;

  signal r, nextr : cpu_t;
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
      when ADD =>
        v.d.dest := unsigned(inst(25 downto 20));
        v.d.data := (others => '0');
        v.d.reg.a1 := unsigned(inst(19 downto 14));
        v.d.reg.a2 := unsigned(inst(13 downto 8));
        data_hazard := find_data_hazard(r, v.d.reg.a1) or
                       find_data_hazard(r, v.d.reg.a2);
        branch_hazard := false;
      when ADDI =>
        v.d.dest := unsigned(inst(25 downto 20));
        v.d.data := unsigned(resize(signed(inst(13 downto 0)), 32));
        v.d.reg.a1 := unsigned(inst(19 downto 14));
        v.d.reg.a2 := (others => '0');
        data_hazard := find_data_hazard(r, v.d.reg.a1);
        branch_hazard := false;
      when others => null;
    end case;

    --execute
    v.e.op := r.d.op;
    v.e.dest := r.d.dest;
    case r.d.op is
      when ADD =>
        v.e.alu.d1 := reg_o.d1;
        v.e.alu.d2 := reg_o.d2;
      when ADDI =>
        v.e.alu.d1 := reg_o.d1;
        v.e.alu.d2 := r.d.data;
      when others => null;
    end case;

    --memory access
    v.m.op := r.e.op;
    v.m.dest := r.e.dest;
    case r.d.op is
      when ADD =>
        v.m.data := alu_o.d;
      when ADDI =>
        v.m.data := alu_o.d;
      when others => null;
    end case;

    -- write
    case r.m.op is
      when ADD | ADDI =>
        v.w.reg.we := '1';
        v.w.reg.a := r.m.dest;
        v.w.reg.d := r.m.data;
      when others => null;
    end case;

    nextr <= v;
    pc <= v.f.pc;
    memi <= vmemi;
  end process;

  update : process(clk)
  begin
    if rising_edge(clk) then
      r <= nextr;
    end if;
  end process;

end arch_control;
