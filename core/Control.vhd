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

  component ftoi is
    port (
      clk : in std_logic;
      stall : in std_logic;
      i : in std_logic_vector(31 downto 0);
      o : out std_logic_vector(31 downto 0));
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

  component finv is
    port (
      clk : in std_logic;
      stall : in std_logic;
      i : in std_logic_vector(31 downto 0);
      o : out std_logic_vector(31 downto 0));
  end component;

  component fcmp is
    port (
      a : in std_logic_vector(31 downto 0);
      b : in std_logic_vector(31 downto 0);
      o : out std_logic_vector(31 downto 0));
  end component;

  procedure forward_gpreg_at_dec
    (gpreg : in regfile_t;
     a : in unsigned(4 downto 0);
     e_d : in write_data_t;
     ma_d : in write_data_t;
     mw_d : in write_data_t;
     mr_d : in write_data_t;
     w_d : in write_data_t;
     d : out read_data_t) is
  begin
    d := default_read_data;
    d.a := a;
    d.f := '0';
    d.h := '1';
    if a /= 0 and a = e_d.a and e_d.f = '0' then
      if e_d.r = '1' then
        d.d := e_d.d;
        d.h := '0';
      end if;
    elsif a /= 0 and a = ma_d.a and ma_d.f = '0' then
      if ma_d.r = '1' then
        d.d := ma_d.d;
        d.h := '0';
      end if;
    elsif a /= 0 and a = mw_d.a and mw_d.f = '0' then
      if mw_d.r = '1' then
        d.d := mw_d.d;
        d.h := '0';
      end if;
    elsif a /= 0 and a = mr_d.a and mr_d.f = '0' then
      if mr_d.r = '1' then
        d.d := mr_d.d;
        d.h := '0';
      end if;
    elsif a /= 0 and a = w_d.a and w_d.f = '0' then
      if w_d.r = '1' then
        d.d := w_d.d;
        d.h := '0';
      end if;
    else
      d.d := gpreg(to_integer(a));
      d.h := '0';
    end if;
  end forward_gpreg_at_dec;

  procedure forward_fpreg_at_dec
    (fpreg : in regfile_t;
     a : in unsigned(4 downto 0);
     e_d : in write_data_t;
     ma_d : in write_data_t;
     mw_d : in write_data_t;
     mr_d : in write_data_t;
     w_d : in write_data_t;
     d : out read_data_t) is
  begin
    d := default_read_data;
    d.a := a;
    d.f := '1';
    d.h := '1';
    if a /= 0 and a = e_d.a and e_d.f = '1' then
      if e_d.r = '1' then
        d.d := e_d.d;
        d.h := '0';
      end if;
    elsif a /= 0 and a = ma_d.a and ma_d.f = '1' then
      if ma_d.r = '1' then
        d.d := ma_d.d;
        d.h := '0';
      end if;
    elsif a /= 0 and a = mw_d.a and mw_d.f = '1' then
      if mw_d.r = '1' then
        d.d := mw_d.d;
        d.h := '0';
      end if;
    elsif a /= 0 and a = mr_d.a and mr_d.f = '1' then
      if mr_d.r = '1' then
        d.d := mr_d.d;
        d.h := '0';
      end if;
    elsif a /= 0 and a = w_d.a and w_d.f = '1' then
      if w_d.r = '1' then
        d.d := w_d.d;
        d.h := '0';
      end if;
    else
      d.d := fpreg(to_integer(a));
      d.h := '0';
    end if;
  end forward_fpreg_at_dec;

  procedure forward_at_exec
    (di  : in read_data_t;
     ma_d : in write_data_t;
     mw_d : in write_data_t;
     mr_d : in write_data_t;
     w_d : in write_data_t;
     do  : out read_data_t) is
  begin
    do := di;
    if di.h = '1' then
      if ma_d.r = '1' and ma_d.a = di.a and ma_d.f = di.f then
        do.d := ma_d.d;
        do.h := '0';
      elsif mw_d.r = '1' and mw_d.a = di.a and mw_d.f = di.f then
        do.d := mw_d.d;
        do.h := '0';
      elsif mr_d.r = '1' and mr_d.a = di.a and mr_d.f = di.f then
        do.d := mr_d.d;
        do.h := '0';
      elsif w_d.r = '1' and w_d.a = di.a and w_d.f = di.f then
        do.d := w_d.d;
        do.h := '0';
      end if;
    end if;
  end forward_at_exec;

  procedure decode
    (i : in std_logic_vector(31 downto 0);
     pc : in unsigned(ADDR_WIDTH-1 downto 0);
     gpreg : in regfile_t;
     fpreg : in regfile_t;
     e_d : in write_data_t;
     ma_d : in write_data_t;
     mw_d : in write_data_t;
     mr_d : in write_data_t;
     w_d : in write_data_t;
     d : out decode_t) is
    variable ra, rb, rc, cr, lr, fa, fb, fc: read_data_t;
  begin

    ---forwarding
    forward_gpreg_at_dec(gpreg, unsigned(i(25 downto 21)), e_d, ma_d, mw_d, mr_d, w_d, ra);
    forward_gpreg_at_dec(gpreg, unsigned(i(20 downto 16)), e_d, ma_d, mw_d, mr_d, w_d, rb);
    forward_gpreg_at_dec(gpreg, unsigned(i(15 downto 11)), e_d, ma_d, mw_d, mr_d, w_d, rc);
    forward_gpreg_at_dec(gpreg, "11110", e_d, ma_d, mw_d, mr_d, w_d, cr);
    forward_gpreg_at_dec(gpreg, "11111", e_d, ma_d, mw_d, mr_d, w_d, lr);

    forward_fpreg_at_dec(fpreg, unsigned(i(25 downto 21)), e_d, ma_d, mw_d, mr_d, w_d, fa);
    forward_fpreg_at_dec(fpreg, unsigned(i(20 downto 16)), e_d, ma_d, mw_d, mr_d, w_d, fb);
    forward_fpreg_at_dec(fpreg, unsigned(i(15 downto 11)), e_d, ma_d, mw_d, mr_d, w_d, fc);

    d := default_d;
    d.pc := pc-1;
    d.op := i(31 downto 26);
    case i(31 downto 26) is
      when LD =>
        d.dest := unsigned(i(25 downto 21));
        d.d1 := rb;
        d.imm := unsigned(resize(signed(i(15 downto 0)), 32));
      when ST =>
        d.d1 := rb;
        d.d2 := ra;
        d.imm := unsigned(resize(signed(i(15 downto 0)), 32));
      when FLD =>
        d.dest := unsigned(i(25 downto 21));
        d.d1 := rb;
        d.imm := unsigned(resize(signed(i(15 downto 0)), 32));
      when FST =>
        d.d1 := rb;
        d.d2 := fa;
        d.imm := unsigned(resize(signed(i(15 downto 0)), 32));
      when I_TOF =>
        d.dest := unsigned(i(25 downto 21));
        d.d1 := rb;
      when F_TOI =>
        d.dest := unsigned(i(25 downto 21));
        d.d1 := fb;
      when ADD | SUB | SH_L | SH_R =>
        d.dest := unsigned(i(25 downto 21));
        d.d1 := rb;
        d.d2 := rc;
      when ADDI | SHLI | SHRI =>
        d.dest := unsigned(i(25 downto 21));
        d.d1 := rb;
        d.imm := unsigned(resize(signed(i(15 downto 0)), 32));
      when LDIH =>
        d.dest := unsigned(i(25 downto 21));
        d.d1 := ra; -- ISA should rb
        d.imm := resize(unsigned(i(15 downto 0)), 32);
      when F_ADD | F_SUB | F_MUL =>
        d.dest := unsigned(i(25 downto 21));
        d.d1 := fb;
        d.d2 := fc;
      when F_ABS | F_INV | F_SQRT =>
        d.dest := unsigned(i(25 downto 21));
        d.d1 := fb;
      when F_CMP =>
        d.dest := "11110";
        d.d1 := fb;
        d.d2 := fc;
      when FLDI =>
        d.dest := unsigned(i(25 downto 21));
        d.d1 := fb;
        d.imm := resize(unsigned(i(15 downto 0)), 32);
      when J =>
        d.imm := unsigned(resize(signed(i(24 downto 0)), 32));
      when JEQ | JLE | JLT =>
        d.d1 := cr;
        d.imm := unsigned(resize(signed(i(24 downto 0)), 32));
      when JSUB =>
        d.dest := "11111";
        d.imm := unsigned(resize(signed(i(24 downto 0)), 32));
      when RET =>
        d.d1 := lr;
      when others =>
    end case;
  end decode;

  procedure execute
    (d : in decode_t;
     ma_d : in write_data_t;
     mw_d : in write_data_t;
     mr_d : in write_data_t;
     w_d : in write_data_t;
     e : out execute_t;
     hazard : out std_logic) is
    variable d1, d2 : read_data_t;
  begin

    forward_at_exec(d.d1, ma_d, mw_d, mr_d, w_d, d1);
    forward_at_exec(d.d2, ma_d, mw_d, mr_d, w_d, d2);

    e := default_e;
    e.pc := d.pc;
    e.op := d.op;
    e.wd.a := d.dest;
    hazard := '0';
    case d.op is
      when LD =>
        e.alu := (d1.d, d.imm, "00");
        hazard := d1.h;
      when FLD =>
        e.alu := (d1.d, d.imm, "00");
        hazard := d1.h;
        e.wd.f := '1';
      when ST | FST =>
        e.alu := (d1.d, d.imm, "00");
        e.data := d2.d;
        e.wd.r := '1';
        hazard := d1.h or d2.h;
      when I_TOF =>
        e.fpu := (d1.d, (others => '-'));
        e.wd.d := d1.d;
        e.wd.f := '1';
        hazard := d1.h;
      when F_TOI =>
        e.fpu := (d1.d, (others => '-'));
        e.wd.d := d1.d;
        hazard := d1.h;
      when ADD =>
        e.alu := (d1.d, d2.d, "00");
        hazard := d1.h or d2.h;
      when SUB =>
        e.alu := (d1.d, d2.d, "01");
        hazard := d1.h or d2.h;
      when ADDI =>
        e.alu := (d1.d, d.imm, "00");
        hazard := d1.h;
      when SH_L =>
        e.alu := (d1.d, d2.d, "10");
        hazard := d1.h or d2.h;
      when SH_R =>
        e.alu := (d1.d, d2.d, "11");
        hazard := d1.h or d2.h;
      when SHLI =>
        e.alu := (d1.d, d.imm, "10");
        hazard := d1.h;
      when SHRI =>
        e.alu := (d1.d, d.imm, "11");
        hazard := d1.h;
      when LDIH =>
        e.wd.d := d.imm(15 downto 0) & d1.d(15 downto 0);
        e.wd.r := '1';
        hazard := d1.h;
      when F_ADD | F_MUL =>
        e.fpu := (d1.d, d2.d);
        e.wd.f := '1';
        hazard := d1.h or d2.h;
      when F_SUB =>
        e.fpu := (d1.d, (not d2.d(31)) & d2.d(30 downto 0));
        e.wd.f := '1';
        hazard := d1.h or d2.h;
      when F_INV | F_SQRT =>
        e.fpu := (d1.d, (others => '-'));
        e.wd.f := '1';
        hazard := d1.h;
      when F_ABS =>
        e.wd.d := '0' & d1.d(30 downto 0);
        e.wd.f := '1';
        e.wd.r := '1';
        hazard := d1.h;
      when F_CMP =>
        e.fpu := (d1.d, d2.d);
        hazard := d1.h or d2.h;
      when FLDI =>
        e.wd.d := d.imm(15 downto 0) & d1.d(31 downto 16);
        e.wd.f := '1';
        e.wd.r := '1';
        hazard := d1.h;
      when J =>
        e.alu := (resize(d.pc, 32), d.imm, "00");
        e.branching := '1';
        e.wd.r := '1';
      when JEQ =>
        e.alu := (resize(d.pc, 32), d.imm, "00");
        if d1.d = 0 then
          e.branching := '1';
        else
          e.branching := '0';
        end if;
        e.wd.r := '1';
        hazard := d1.h;
      when JLE =>
        e.alu := (resize(d.pc, 32), d.imm, "00");
        if d1.d(31) = '1' or d1.d = 0 then
          e.branching := '1';
        else
          e.branching := '0';
        end if;
        e.wd.r := '1';
        hazard := d1.h;
      when JLT =>
        e.alu := (resize(d.pc, 32), d.imm, "00");
        if d1.d(31) = '1' then
          e.branching := '1';
        else
          e.branching := '0';
        end if;
        e.wd.r := '1';
        hazard := d1.h;
      when JSUB =>
        e.alu := (resize(d.pc, 32), d.imm, "00");
        e.branching := '1';
        e.wd.d := resize(d.pc, 32);
        e.wd.r := '1';
      when RET =>
        e.alu := (d1.d, x"00000001", "00");
        e.branching := '1';
        e.wd.r := '1';
        hazard := d1.h;
      when others =>
    end case;
  end execute;

  procedure memory_access
    (e : in execute_t;
     alu : in unsigned(31 downto 0);
     fcmp_o : in unsigned(31 downto 0);
     ma : out memory_access_t) is
  begin
    ma := default_ma;
    ma.op := e.op;
    ma.wd := e.wd;
    case e.op is
      when LD =>
        ma.m := (alu(19 downto 0), (others => '-'), '1', '0', '0');
      when FLD =>
        ma.m := (alu(19 downto 0), (others => '-'), '1', '0', '1');
      when ST =>
        ma.m := (alu(19 downto 0), e.data, '1', '1', '0');
      when FST =>
        ma.m := (alu(19 downto 0), e.data, '1', '1', '1');
      when ADD | SUB | ADDI | SH_L | SH_R | SHLI | SHRI =>
        ma.wd.d := alu;
        ma.wd.r := '1';
      when F_CMP =>
        ma.wd.d := fcmp_o;
        ma.wd.r := '1';
      when others =>
    end case;
  end memory_access;

  procedure memory_wait
    (ma : in memory_access_t;
     mw: out memory_wait_t) is
  begin
    mw.op := ma.op;
    mw.wd := ma.wd;
  end memory_wait;

  procedure memory_read
    (mw : in memory_wait_t;
     mem_o : in unsigned(31 downto 0);
     mr : out memory_read_t) is
  begin
    mr := default_mr;
    mr.op := mw.op;
    mr.wd := mw.wd;
    case mw.op is
      when LD | FLD =>
        mr.wd.d := mem_o;
        mr.wd.r := '1';
      when others =>
    end case;
  end memory_read;

  procedure write_back
    (mr : in memory_read_t;
     ftoi_o : in unsigned(31 downto 0);
     itof_o : in unsigned(31 downto 0);
     fadd_o : in unsigned(31 downto 0);
     fmul_o : in unsigned(31 downto 0);
     finv_o : in unsigned(31 downto 0);
     w : out write_data_t) is
  begin
    w := mr.wd;
    case mr.op is
      when F_TOI =>
        w.d := ftoi_o;
        w.r := '1';
      when I_TOF =>
        w.d := itof_o;
        w.r := '1';
      when F_ADD =>
        w.d := fadd_o;
        w.r := '1';
      when F_SUB =>
        w.d := fadd_o;
        w.r := '1';
      when F_MUL =>
        w.d := fmul_o;
        w.r := '1';
      when F_INV =>
        w.d := finv_o;
        w.r := '1';
      when others =>
    end case;
  end procedure;

  signal r : cpu_t := init_r;
  signal gpreg : regfile_t := init_regfile;
  signal fpreg : regfile_t := init_regfile;
  signal alu_o : unsigned(31 downto 0);
  signal ftoi_o : std_logic_vector(31 downto 0);
  signal itof_o : std_logic_vector(31 downto 0);
  signal fadd_o : std_logic_vector(31 downto 0);
  signal fmul_o : std_logic_vector(31 downto 0);
  signal finv_o : std_logic_vector(31 downto 0);
  signal fcmp_o : std_logic_vector(31 downto 0);

begin
  bus_out.pc <= r.pc;
  bus_out.m <= r.ma.m;

  alu_unit : alu port map (
    di => r.e.alu,
    do => alu_o);

  ftoi_unit : ftoi port map (
    clk => clk,
    stall => bus_in.m.stall,
    i => std_logic_vector(r.e.fpu.d1),
    o => ftoi_o);

  fadd_unit : fadd port map (
    clk => clk,
    stall => bus_in.m.stall,
    a => std_logic_vector(r.e.fpu.d1),
    b => std_logic_vector(r.e.fpu.d2),
    o => fadd_o);

  fmul_unit : fmul port map (
    clk => clk,
    stall => bus_in.m.stall,
    a => std_logic_vector(r.e.fpu.d1),
    b => std_logic_vector(r.e.fpu.d2),
    o => fmul_o);

  finv_unit : finv port map (
    clk => clk,
    stall => bus_in.m.stall,
    i => std_logic_vector(r.e.fpu.d1),
    o => finv_o);

  fcmp_unit : fcmp port map (
    a => std_logic_vector(r.e.fpu.d1),
    b => std_logic_vector(r.e.fpu.d2),
    o => fcmp_o);

  control_unit : process(clk)
    variable v : cpu_t;
    variable v_wd : write_data_t;
    variable data_hazard : std_logic;
    variable control_hazard : std_logic;
    variable mem_stall : std_logic;
  begin

    if rising_edge(clk) then
      v := r;

      if r.state = "000" then
        v.ibuf := bus_in.i;
        v.pc := r.pc;
      else
        v.ibuf := r.ibuf;
        v.pc := r.pcbuf;
      end if;

      memory_access(r.e, alu_o, unsigned(fcmp_o), v.ma);
      memory_wait(r.ma, v.mw);
      memory_read(r.mw, bus_in.m.d, v.mr);
      write_back(r.mr, unsigned(ftoi_o), unsigned(itof_o),
                 unsigned(fadd_o), unsigned(fmul_o), unsigned(finv_o), v_wd);

      execute(r.d, v.ma.wd, v.mw.wd, v.mr.wd, v_wd, v.e, data_hazard);
      decode(v.ibuf, v.pc, gpreg, fpreg, v.e.wd, v.ma.wd, v.mw.wd, v.mr.wd, v_wd, v.d);

      mem_stall := bus_in.m.stall;
      control_hazard := r.e.branching;

      if mem_stall = '0' then
        if control_hazard = '0' then
          if data_hazard = '0' then
            v.state := "000";
            v.pc := r.pc+1;
          else -- data_hazard = '1'
            v.state := "001";
            if r.state = "000" then
              v.ibuf := bus_in.i;
              v.pcbuf := r.pc;
            end if;
          end if;
        else -- control_hazard = '1'
          v.state := "010";
          v.pc := alu_o(11 downto 0);
        end if;
        --decode
        if control_hazard = '0' and r.state /= "010" then
          if data_hazard = '1' then
            v.d := r.d;
          end if;
        else
          v.d := default_d;
        end if;
        --execute
        if control_hazard = '0' and r.state /= "010" then
          if data_hazard = '1' then
            v.e := default_e;
          end if;
        else
          v.e := default_e;
        end if;
        --memory
        -- write
        if v_wd.f = '0' then
          gpreg(to_integer(v_wd.a)) <= v_wd.d;
        else
          fpreg(to_integer(v_wd.a)) <= v_wd.d;
        end if;

      else -- mem_stall = '1'
        v := r;
        v.state := "011";
        if r.state = "000" or r.state = "010" then
          v.ibuf := bus_in.i;
          v.pcbuf := r.pc;
        end if;
        v.ma.m := default_memory_request;
      end if;

      r <= v;

    end if;

  end process;

end Control_arch;
