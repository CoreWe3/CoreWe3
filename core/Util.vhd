library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Util is
  constant ADDR_WIDTH : integer := 12;

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
    busy : std_logic;
  end record mem_out_t;

  type mem_t is record
    a : unsigned(19 downto 0);
    d : unsigned(31 downto 0);
    go : std_logic;
    we : std_logic;
  end record mem_t;

  type mem_in_t is record
    pc : unsigned(11 downto 0);
    m : mem_t;
  end record mem_in_t;

  constant default_mem : mem_t := (
    a => (others => '-'),
    d => (others => '-'),
    go => '0',
    we => '0');

  type alu_in_t is record
    d1 : unsigned(31 downto 0);
    d2 : unsigned(31 downto 0);
    ctrl : unsigned(1 downto 0);
  end record alu_in_t;

  constant default_alu : alu_in_t := (
    d1 => (others => '0'),
    d2 => (others => '0'),
    ctrl => (others => '0'));

  type alu_out_t is record
    d : unsigned(31 downto 0);
  end record alu_out_t;

  type fpu_in_t is record
    d1 : unsigned(31 downto 0);
    d2 : unsigned(31 downto 0);
  end record fpu_in_t;

  constant default_fpu_in : fpu_in_t := (
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

  type data_t is record
    d : unsigned(31 downto 0);
    hazard : std_logic;
    alu_forward : std_logic;
    mem_forward : std_logic;
  end record;

  constant default_data : data_t :=
    (d => (others => '0'),
     hazard => '0',
     alu_forward => '0',
     mem_forward => '0');

  type decode_t is record
    pc    : unsigned(ADDR_WIDTH-1 downto 0);
    op    : std_logic_vector(5 downto 0);
    d1    : data_t;
    d2    : data_t;
    dest  : unsigned(4 downto 0);
    imm   : unsigned(31 downto 0);
  end record decode_t;

  constant default_d : decode_t := (
    pc => (others => '-'),
    op => ADD,
    d1 => default_data,
    d2 => default_data,
    dest => (others => '0'),
    imm => (others => '-'));

  type execute_t is record
    op     : std_logic_vector(5 downto 0);
    pc     : unsigned(ADDR_WIDTH-1 downto 0);
    dest   : unsigned(4 downto 0);
    data   : unsigned(31 downto 0);
    branching : std_logic;
    alu    : alu_in_t;
    fpu    : fpu_in_t;
  end record execute_t;

  constant default_e : execute_t := (
    op => ADD,
    pc => (others => '-'),
    dest => (others => '0'),
    data => (others => '-'),
    branching => '0',
    alu => default_alu,
    fpu => default_fpu_in);

  type memory_access_t is record
    op     : std_logic_vector(5 downto 0);
    dest   : unsigned(4 downto 0);
    data   : unsigned(31 downto 0);
    mem    : mem_t;
  end record memory_access_t;

  constant default_m : memory_access_t := (
    op => ADD,
    dest => (others => '0'),
    data => (others => '0'),
    mem => default_mem);


  type cpu_t is record
    state : std_logic_vector(1 downto 0);
    branched : std_logic;
    pc : unsigned(11 downto 0);
    inst_buf : std_logic_vector(31 downto 0);
    d : decode_t;
    e : execute_t;
    m : memory_access_t;
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
    m => default_m,
    gpreg => init_regfile,
    fpreg => init_regfile);

  procedure get_gpreg
    (r : in cpu_t;
     n : in unsigned(4 downto 0);
     alu : in unsigned(31 downto 0);
     mem : in unsigned(31 downto 0);
     d : out data_t);

  procedure forwarding
    (data_in : in data_t;
     alu : in unsigned(31 downto 0);
     mem : in unsigned(31 downto 0);
     data_out : out unsigned(31 downto 0));

  procedure decode
    (r : in cpu_t;
     i : in std_logic_vector(31 downto 0);
     alu : in unsigned(31 downto 0);
     mem : in unsigned(31 downto 0);
     d : out decode_t;
     data_hazard : out std_logic);

  procedure execute
    (r : in cpu_t;
     alu : in unsigned(31 downto 0);
     mem : in unsigned(31 downto 0);
     e : out execute_t);

  procedure memory_access
    (r : in cpu_t;
     alu : in unsigned(31 downto 0);
     m : out memory_access_t);

end package Util;

package body Util is

  procedure get_gpreg
    (r : in cpu_t;
     n : in unsigned(4 downto 0);
     alu : in unsigned(31 downto 0);
     mem : in unsigned(31 downto 0);
     d : out data_t) is
  begin
    if n = r.d.dest and n /= 0 then
      d.mem_forward := '0';
      case r.d.op is
        when ADD | SUB | ADDI | SHLI | SHRI =>
          d.d := (others => '-');
          d.hazard := '0';
          d.alu_forward := '1';
        when JSUB =>
          d.d := resize(r.d.pc, 32);
          d.hazard := '0';
          d.alu_forward := '0';
        when others =>
          d.d := (others => '-');
          d.hazard := '1';
          d.alu_forward := '0';
      end case;
    elsif n = r.e.dest and n /= 0 then
      d.alu_forward := '0';
      case r.e.op is
        when LD =>
          d.d := (others => '-');
          d.hazard := '0';
          d.mem_forward := '1';
        when ADD | SUB | ADDI | SHLI | SHRI =>
          d.d := alu;
          d.hazard := '0';
          d.mem_forward := '0';
        when LDIH =>
          d.d := r.e.data;
          d.hazard := '0';
          d.mem_forward := '0';
        when JSUB =>
          d.d := resize(r.e.pc, 32);
          d.hazard := '0';
          d.mem_forward := '0';
        when others =>
          d.d := (others => '-');
          d.hazard := '1';
          d.mem_forward := '0';
      end case;
    elsif n = r.m.dest and n /= 0 then
      d.alu_forward := '0';
      d.mem_forward := '0';
      case r.m.op is
        when LD =>
          d.d := mem;
          d.hazard := '0';
        when ADD | SUB | ADDI | SHLI | SHRI | JSUB | LDIH =>
          d.d := r.m.data;
          d.hazard := '0';
        when others =>
          d.d := (others => '-');
          d.hazard := '1';
      end case;
    else
      d.d := r.gpreg(to_integer(n));
      d.hazard := '0';
      d.alu_forward := '0';
      d.mem_forward := '0';
    end if;
  end get_gpreg;

  procedure forwarding
    (data_in : in data_t;
     alu : in unsigned(31 downto 0);
     mem : in unsigned(31 downto 0);
     data_out : out unsigned(31 downto 0)) is
  begin
    if data_in.alu_forward = '1' then
      data_out := alu;
    elsif data_in.mem_forward = '1' then
      data_out := mem;
    else
      data_out := data_in.d;
    end if;
  end forwarding;

  procedure decode
    (r : in cpu_t;
     i : in std_logic_vector(31 downto 0);
     alu : in unsigned(31 downto 0);
     mem : in unsigned(31 downto 0);
     d : out decode_t;
     data_hazard : out std_logic) is
    variable da, db, dc, cr, lr : data_t;
  begin

    ---forwarding
    get_gpreg(r, unsigned(i(25 downto 21)), alu, mem, da);
    get_gpreg(r, unsigned(i(20 downto 16)), alu, mem, db);
    get_gpreg(r, unsigned(i(15 downto 11)), alu, mem, dc);
    get_gpreg(r, "11110", alu, mem, cr);
    get_gpreg(r, "11111", alu, mem, lr);

    d.pc := r.pc-1;
    d.op := i(31 downto 26);
    case i(31 downto 26) is
      when LD =>
        d.dest := unsigned(i(25 downto 21));
        d.d1 := db;
        d.d2 := default_data;
        d.imm := unsigned(resize(signed(i(15 downto 0)), 32));
        data_hazard := db.hazard;
      when ST =>
        d.dest := (others => '0');
        d.d1 := da;
        d.d2 := db;
        d.imm := unsigned(resize(signed(i(15 downto 0)), 32));
        data_hazard := da.hazard or db.hazard;
      when ADD | SUB =>
        d.dest := unsigned(i(25 downto 21));
        d.d1 := db;
        d.d2 := dc;
        d.imm := (others => '-');
        data_hazard := db.hazard or dc.hazard;
      when ADDI =>
        d.dest := unsigned(i(25 downto 21));
        d.d1 := db;
        d.d2 := default_data;
        d.imm := unsigned(resize(signed(i(15 downto 0)), 32));
        data_hazard := db.hazard;
      when SHLI | SHRI =>
        d.dest := unsigned(i(25 downto 21));
        d.d1 := db;
        d.d2 := default_data;
        d.imm := unsigned(resize(signed(i(15 downto 0)), 32));
        data_hazard := db.hazard;
      when LDIH =>
        d.dest := unsigned(i(25 downto 21));
        d.d1 := da;
        d.d2 := default_data;
        d.imm := resize(unsigned(i(15 downto 0)), 32);
        data_hazard := da.hazard;
      when J =>
        d.dest := (others => '0');
        d.d1 := default_data;
        d.d2 := default_data;
        d.imm := unsigned(resize(signed(i(24 downto 0)), 32));
        data_hazard := '0';
      when JEQ | JLE | JLT =>
        d.dest := (others => '0');
        d.d1 := cr;
        d.d2 := default_data;
        d.imm := unsigned(resize(signed(i(24 downto 0)), 32));
        data_hazard := cr.hazard;
      when JSUB =>
        d.dest := "11111";
        d.d1 := default_data;
        d.d2 := default_data;
        d.imm := unsigned(resize(signed(i(24 downto 0)), 32));
        data_hazard := '0';
      when RET =>
        d.dest := (others => '0');
        d.d1 := lr;
        d.d2 := default_data;
        d.imm := (others => '-');
        data_hazard := lr.hazard;
      when others =>
        d := default_d;
        data_hazard := '0';
    end case;
  end decode;

  procedure execute
    (r : in cpu_t;
     alu : in unsigned(31 downto 0);
     mem : in unsigned(31 downto 0);
     e : out execute_t) is
    variable d1_forwarded, d2_forwarded : unsigned(31 downto 0);
  begin

    forwarding(r.d.d1, alu, mem, d1_forwarded);
    forwarding(r.d.d2, alu, mem, d2_forwarded);

    e.pc := r.d.pc;
    e.op := r.d.op;
    e.dest := r.d.dest;
    case r.d.op is
      when LD =>
        e.alu := (d1_forwarded, r.d.imm, "00");
        e.branching := '0';
        e.fpu := default_fpu_in;
        e.data := (others => '-');
      when ST =>
        e.alu := (d2_forwarded, r.d.imm, "00");
        e.branching := '0';
        e.fpu := default_fpu_in;
        e.data := d1_forwarded;
      when ADD =>
        e.alu := (d1_forwarded, d2_forwarded, "00");
        e.branching := '0';
        e.fpu := default_fpu_in;
        e.data := (others => '-');
      when SUB =>
        e.alu := (d1_forwarded, d2_forwarded, "01");
        e.branching := '0';
        e.fpu := default_fpu_in;
        e.data := (others => '-');
      when ADDI =>
        e.alu := (d1_forwarded, r.d.imm, "00");
        e.branching := '0';
        e.fpu := default_fpu_in;
        e.data := (others => '-');
      when SHLI =>
        e.alu := (d1_forwarded, r.d.imm, "10");
        e.branching := '0';
        e.fpu := default_fpu_in;
        e.data := (others => '-');
      when SHRI =>
        e.alu := (d1_forwarded, r.d.imm, "11");
        e.branching := '0';
        e.fpu := default_fpu_in;
        e.data := (others => '-');
      when LDIH =>
        e.alu := default_alu;
        e.branching := '0';
        e.fpu := default_fpu_in;
        e.data := r.d.imm(15 downto 0) & d1_forwarded(15 downto 0);
      when J =>
        e.alu := (resize(r.d.pc, 32), r.d.imm, "00");
        e.branching := '1';
        e.fpu := default_fpu_in;
        e.data := (others => '-');
      when JEQ =>
        e.alu := (resize(r.d.pc, 32), r.d.imm, "00");
        if d1_forwarded = 0 then
          e.branching := '1';
        else
          e.branching := '0';
        end if;
        e.fpu := default_fpu_in;
        e.data := (others => '-');
      when JLE =>
        e.alu := (resize(r.d.pc, 32), r.d.imm, "00");
        if d1_forwarded(31) = '1' or d1_forwarded = 0 then
          e.branching := '1';
        else
          e.branching := '0';
        end if;
        e.fpu := default_fpu_in;
        e.data := (others => '-');
      when JLT =>
        e.alu := (resize(r.d.pc, 32), r.d.imm, "00");
        if d1_forwarded(31) = '1' then
          e.branching := '1';
        else
          e.branching := '0';
        end if;
        e.fpu := default_fpu_in;
        e.data := (others => '-');
      when JSUB =>
        e.alu := (resize(r.d.pc, 32), r.d.imm, "00");
        e.branching := '1';
        e.fpu := default_fpu_in;
        e.data := resize(r.d.pc, 32);
      when RET =>
        e.alu := (d1_forwarded, x"00000001", "00");
        e.branching := '1';
        e.fpu := default_fpu_in;
        e.data := (others => '-');
      when others =>
        e := default_e;
    end case;
  end execute;

  procedure memory_access
    (r : in cpu_t;
     alu : in unsigned(31 downto 0);
     m : out memory_access_t) is
  begin

    m.op := r.e.op;
    m.dest := r.e.dest;
    case r.e.op is
      when LD =>
        m.data := (others => '-');
        m.mem := (alu(19 downto 0), (others => '-'), '1', '0');
      when ST =>
        m.data := (others => '-');
        m.mem := (alu(19 downto 0), r.e.data, '1', '1');
      when ADD | SUB | ADDI | SHLI | SHRI =>
        m.data := alu;
        m.mem := default_mem;
      when LDIH =>
        m.data := r.e.data;
        m.mem := default_mem;
      when J | JEQ | JLE | JLT =>
        m.data := (others => '-');
        m.mem := default_mem;
      when JSUB =>
        m.data := r.e.data;
        m.mem := default_mem;
      when RET =>
        m.data := (others => '-');
        m.mem := default_mem;
      when others =>
        m.data := (others => '-');
        m.mem := default_mem;
    end case;
  end memory_access;


end Util;
