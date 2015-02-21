library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Util is
  constant ADDR_WIDTH : integer := 12;
  constant CACHE_WIDTH : integer := 8;

  constant LD    : std_logic_vector(5 downto 0) := "000000";
  constant ST    : std_logic_vector(5 downto 0) := "000001";
  constant FLD   : std_logic_vector(5 downto 0) := "000010";
  constant FST   : std_logic_vector(5 downto 0) := "000011";
  constant ITOF  : std_logic_vector(5 downto 0) := "000100";
  constant FTOI  : std_logic_vector(5 downto 0) := "000101";
  constant ADD   : std_logic_vector(5 downto 0) := "000110";
  constant SUB   : std_logic_vector(5 downto 0) := "000111";
  constant ADDI  : std_logic_vector(5 downto 0) := "001000";
  constant SH_L  : std_logic_vector(5 downto 0) := "001001";
  constant SH_R  : std_logic_vector(5 downto 0) := "001010";
  constant SHLI  : std_logic_vector(5 downto 0) := "001011";
  constant SHRI  : std_logic_vector(5 downto 0) := "001100";
  constant LDIH  : std_logic_vector(5 downto 0) := "001101";
  constant F_ADD : std_logic_vector(5 downto 0) := "001110";
  constant F_SUB : std_logic_vector(5 downto 0) := "001111";
  constant F_MUL : std_logic_vector(5 downto 0) := "010000";
  constant F_INV : std_logic_vector(5 downto 0) := "010001";
  constant F_SQRT: std_logic_vector(5 downto 0) := "010010";
  constant F_ABS : std_logic_vector(5 downto 0) := "010011";
  constant FCMP  : std_logic_vector(5 downto 0) := "010100";
  constant FLDIL : std_logic_vector(5 downto 0) := "010101";
  constant FLDIH : std_logic_vector(5 downto 0) := "010110";
  constant J     : std_logic_vector(5 downto 0) := "010111";
  constant JEQ   : std_logic_vector(5 downto 0) := "011000";
  constant JLE   : std_logic_vector(5 downto 0) := "011001";
  constant JLT   : std_logic_vector(5 downto 0) := "011010";
  constant JSUB  : std_logic_vector(5 downto 0) := "011011";
  constant RET   : std_logic_vector(5 downto 0) := "011100";

  constant EOF   : std_logic_vector(5 downto 0) := "111111";

  type mem_out_t is record
    i : std_logic_vector(31 downto 0);
    d : unsigned(31 downto 0);
    stall : std_logic;
  end record mem_out_t;

  type mem_t is record
    a : unsigned(19 downto 0);
    d : unsigned(31 downto 0);
    go : std_logic;
    we : std_logic;
    f : std_logic;
  end record mem_t;

  type mem_in_t is record
    pc : unsigned(11 downto 0);
    m : mem_t;
  end record mem_in_t;

  constant default_mem : mem_t := (
    a => (others => '-'),
    d => (others => '-'),
    go => '0',
    we => '0',
    f => '0');

  type alu_in_t is record
    d1 : unsigned(31 downto 0);
    d2 : unsigned(31 downto 0);
    ctrl : unsigned(1 downto 0);
  end record alu_in_t;

  constant default_alu : alu_in_t := (
    d1 => (others => '0'),
    d2 => (others => '0'),
    ctrl => (others => '0'));

  type fpu_in_t is record
    stall : std_logic;
    d1 : unsigned(31 downto 0);
    d2 : unsigned(31 downto 0);
  end record fpu_in_t;

  constant default_fpu_in : fpu_in_t := (
    stall => '0',
    d1 => (others => '-'),
    d2 => (others => '-'));

  type regfile_t is array(0 to 31) of unsigned(31 downto 0);

  constant init_regfile : regfile_t := (
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000");

  type read_data_t is record
    a : unsigned(4 downto 0);  --address(register)
    d : unsigned(31 downto 0); -- data
    f : std_logic;             -- float
    h : std_logic;             -- hazard
  end record;

  constant default_read_data : read_data_t :=
    (a => (others => '0'),
     d => (others => '0'),
     f => '0',
     h => '0');

  type write_data_t is record
    a : unsigned(4 downto 0);  -- address(register)
    d : unsigned(31 downto 0); -- data
    f : std_logic;             -- float
    r : std_logic;             -- ready
  end record;

  constant default_write_data : write_data_t :=
    (a => (others => '0'),
     d => (others => '0'),
     f => '0',
     r => '0');

  type decode_t is record
    pc    : unsigned(ADDR_WIDTH-1 downto 0);
    op    : std_logic_vector(5 downto 0);
    d1    : read_data_t;
    d2    : read_data_t;
    dest  : unsigned(4 downto 0);
    imm   : unsigned(31 downto 0);
  end record decode_t;

  constant default_d : decode_t := (
    pc => (others => '-'),
    op => ADD,
    d1 => default_read_data,
    d2 => default_read_data,
    dest => (others => '0'),
    imm => (others => '-'));

  type execute_t is record
    op     : std_logic_vector(5 downto 0);
    pc     : unsigned(ADDR_WIDTH-1 downto 0);
    data   : unsigned(31 downto 0);
    branching : std_logic;
    alu    : alu_in_t;
    fpu    : fpu_in_t;
    wd : write_data_t;
  end record execute_t;

  constant default_e : execute_t := (
    op => ADD,
    pc => (others => '-'),
    data => (others => '-'),
    branching => '0',
    alu => default_alu,
    fpu => default_fpu_in,
    wd => default_write_data);

  type memory_access_t is record
    op     : std_logic_vector(5 downto 0);
    mem    : mem_t;
    wd     : write_data_t;
  end record memory_access_t;

  constant default_ma : memory_access_t := (
    op => ADD,
    mem => default_mem,
    wd => default_write_data);

  type memory_wait_t is record
    op : std_logic_vector(5 downto 0);
    wd : write_data_t;
  end record memory_wait_t;

  constant default_mw : memory_wait_t := (
    op => ADD,
    wd => default_write_data);

  type cpu_t is record
    state : std_logic_vector(1 downto 0);
    branched : std_logic;
    pc : unsigned(11 downto 0);
    inst_buf : std_logic_vector(31 downto 0);
    d : decode_t;
    e : execute_t;
    ma : memory_access_t;
    mw : memory_wait_t;
    gpreg : regfile_t;
    fpreg : regfile_t;
  end record cpu_t;

  constant init_r : cpu_t := (
    state => "00",
    branched => '0',
    pc => (others => '0'),
    inst_buf => (others => '-'),
    d => default_d,
    e => default_e,
    ma => default_ma,
    mw => default_mw,
    gpreg => init_regfile,
    fpreg => init_regfile);

  procedure forward_gpreg_at_dec
    (gpreg : in regfile_t;
     a : in unsigned(4 downto 0);
     e_d : in write_data_t;
     ma_d : in write_data_t;
     mw_d : in write_data_t;
     w_d : in write_data_t;
     d : out read_data_t);

  procedure forward_fpreg_at_dec
    (fpreg : in regfile_t;
     a : in unsigned(4 downto 0);
     e_d : in write_data_t;
     ma_d : in write_data_t;
     mw_d : in write_data_t;
     w_d : in write_data_t;
     d : out read_data_t);

  procedure forward_at_exec
    (di : in read_data_t;
     ma_d : in write_data_t;
     mw_d : in write_data_t;
     w_d : in write_data_t;
     do : out read_data_t);

  procedure decode
    (i : in std_logic_vector(31 downto 0);
     pc : in unsigned(ADDR_WIDTH-1 downto 0);
     gpreg : in regfile_t;
     fpreg : in regfile_t;
     e_d : in write_data_t;
     ma_d : in write_data_t;
     mw_d : in write_data_t;
     w_d : in write_data_t;
     d : out decode_t);

  procedure execute
    (d : in decode_t;
     ma_d : in write_data_t;
     mw_d : in write_data_t;
     w_d : in write_data_t;
     e : out execute_t;
     hazard : out std_logic);

  procedure memory_access
    (e : in execute_t;
     alu : in unsigned(31 downto 0);
     ma : out memory_access_t);

  procedure memory_wait
    (ma : in memory_access_t;
     mw: out memory_wait_t);

  procedure write_back
    (mw : in memory_wait_t;
     mem : in unsigned(31 downto 0);
     fadd_o : in unsigned(31 downto 0);
     fmul_o : in unsigned(31 downto 0);
     w : out write_data_t);

end package Util;

package body Util is

  procedure forward_gpreg_at_dec
    (gpreg : in regfile_t;
     a : in unsigned(4 downto 0);
     e_d : in write_data_t;
     ma_d : in write_data_t;
     mw_d : in write_data_t;
     w_d : in write_data_t;
     d : out read_data_t) is
  begin
    d := default_read_data;
    d.a := a;
    d.f := '0';
    d.h := '1';
    if a = e_d.a and a /= 0 then
      if e_d.r = '1' then
        d.d := e_d.d;
        d.h := '0';
      end if;
    elsif a = ma_d.a and a /= 0 then
      if ma_d.r = '1' then
        d.d := ma_d.d;
        d.h := '0';
      end if;
    elsif a = mw_d.a and a /= 0 then
      if mw_d.r = '1' then
        d.d := mw_d.d;
        d.h := '0';
      end if;
    elsif a = w_d.a and a /= 0 then
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
     w_d : in write_data_t;
     d : out read_data_t) is
  begin
    d := default_read_data;
    d.a := a;
    d.f := '1';
    d.h := '1';
    if a = e_d.a and a /= 0 then
      if e_d.r = '1' then
        d.d := e_d.d;
        d.h := '0';
      end if;
    elsif a = ma_d.a and a /= 0 then
      if ma_d.r = '1' then
        d.d := ma_d.d;
        d.h := '0';
      end if;
    elsif a = mw_d.a and a /= 0 then
      if mw_d.r = '1' then
        d.d := mw_d.d;
        d.h := '0';
      end if;
    elsif a = w_d.a and a /= 0 then
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
     w_d : in write_data_t;
     d : out decode_t) is
    variable ra, rb, rc, cr, lr, fb, fc: read_data_t;
  begin

    ---forwarding
    forward_gpreg_at_dec(gpreg, unsigned(i(25 downto 21)), e_d, ma_d, mw_d, w_d, ra);
    forward_gpreg_at_dec(gpreg, unsigned(i(20 downto 16)), e_d, ma_d, mw_d, w_d, rb);
    forward_gpreg_at_dec(gpreg, unsigned(i(15 downto 11)), e_d, ma_d, mw_d, w_d, rc);
    forward_gpreg_at_dec(gpreg, "11110", e_d, ma_d, mw_d, w_d, cr);
    forward_gpreg_at_dec(gpreg, "11111", e_d, ma_d, mw_d, w_d, lr);

    forward_fpreg_at_dec(fpreg, unsigned(i(25 downto 21)), e_d, ma_d, mw_d, w_d, fb);
    forward_fpreg_at_dec(fpreg, unsigned(i(20 downto 16)), e_d, ma_d, mw_d, w_d, fc);

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
        d.d1 := rb;
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
     w_d : in write_data_t;
     e : out execute_t;
     hazard : out std_logic) is
    variable d1, d2 : read_data_t;
  begin

    forward_at_exec(d.d1, ma_d, mw_d, w_d, d1);
    forward_at_exec(d.d2, ma_d, mw_d, w_d, d2);

    e := default_e;
    e.pc := d.pc;
    e.op := d.op;
    e.wd.a := d.dest;
    case d.op is
      when LD =>
        e.alu := (d1.d, d.imm, "00");
        hazard := d1.h;
      when ST =>
        e.alu := (d1.d, d.imm, "00");
        e.data := d2.d;
        e.wd.r := '1';
        hazard := d1.h or d2.h;
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
      when J =>
        e.alu := (resize(d.pc, 32), d.imm, "00");
        e.branching := '1';
        e.wd.r := '1';
        hazard := '0';
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
        hazard := '0';
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
     ma : out memory_access_t) is
  begin
    ma := default_ma;
    ma.op := e.op;
    ma.wd := e.wd;
    case e.op is
      when LD =>
        ma.mem := (alu(19 downto 0), (others => '-'), '1', '0', '0');
      when ST =>
        ma.mem := (alu(19 downto 0), e.data, '1', '1', '0');
      when ADD | SUB | ADDI | SH_L | SH_R | SHLI | SHRI =>
        ma.wd.d := alu;
        ma.wd.r := '1';
      when LDIH =>
      when J | JEQ | JLE | JLT =>
      when JSUB =>
      when RET =>
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

  procedure write_back
    (mw : in memory_wait_t;
     mem : in unsigned(31 downto 0);
     fadd_o : in unsigned(31 downto 0);
     fmul_o : in unsigned(31 downto 0);
     w : out write_data_t) is
  begin
    w := mw.wd;
    case mw.op is
      when LD =>
        w.d := mem;
        w.r := '1';
      when ADD | SUB | ADDI | SH_L | SH_R | SHLI | SHRI | LDIH | JSUB =>
      when F_ADD =>
        w.d := fadd_o;
        w.r := '1';
      when F_MUL =>
        w.d := fmul_o;
        w.r := '1';
      when others =>
    end case;
  end procedure;

end Util;
