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

  function detect_data_hazard(rf : unsigned(5 downto 0);
                              v : cpu_t) return std_logic is
    variable result : std_logic;
  begin
    result := '0';
    if rf /= 0 then
      if v.data_hazard = '0' then
        if rf = v.d.dest or rf = v.e.dest or
          rf = v.m.dest then
          result := '1';
        end if;
      else
        if rf = v.e.dest or rf = v.m.dest then
          result := '1';
        end if;
      end if;
    end if;
    return result;
  end function detect_data_hazard;

  signal r : cpu_t := init_r;
  signal alu_o : alu_out_t;
  signal reg_o : reg_out_t;
  signal setup : unsigned(1 downto 0) := (others => '0');

begin
  pc <= r.f.pc;

  reg : registers port map (
    clk => clk,
    rdi => r.d.reg,
    wdi => r.w.reg,
    do => reg_o);

  alu0 : alu port map (
    di => r.e.alu,
    do => alu_o);

  main : process(clk)
    variable v : cpu_t;
    variable op : std_logic_vector(5 downto 0);
    variable ra, rb, rc : unsigned(5 downto 0);
    variable data_hazard : std_logic;
    variable mem_stall : std_logic;
  begin
    if rising_edge(clk) then
      v := r;

      op := inst(31 downto 26);
      ra := unsigned(inst(25 downto 20));
      rb := unsigned(inst(19 downto 14));
      rc := unsigned(inst(13 downto 8));

      --detect data hazard
      --case op is
      --  when ST =>
      --    data_hazard := detect_data_hazard(ra, v) or
      --                   detect_data_hazard(rb, v);
      --  when others =>
      --    data_hazard := '0';
      --end case;
      data_hazard := '0';

      --ready
      if setup = 3 then
        --stall for memory access
        if r.mem.go = '0' and memo.busy = '0' then

          --fetch
          if r.e.branch = '0' then
            r.f.pc <= r.f.pc+1;
          else -- elsif r.e.branch = '1' then
            r.f.pc <= alu_o.d(ADDR_WIDTH-1 downto 0);
          end if;


          --decode
          if r.e.branch = '0' then
            r.d.pc <= r.f.pc;
            r.d.op <= op;
            case op is
              when ST =>
                r.d.dest <= (others => '0');
                r.d.data <= unsigned(resize(
                  signed(inst(13 downto 0)), 32));
                r.d.reg.a1 <= ra;
                r.d.reg.a2 <= rb;
              when ADD =>
                r.d.dest <= ra;
                r.d.data <= (others => '0');
                r.d.reg.a1 <= rb;
                r.d.reg.a2 <= rc;
              when ADDI =>
                r.d.dest <= ra;
                r.d.data <= unsigned(resize(
                  signed(inst(13 downto 0)), 32));
                r.d.reg.a1 <= rb;
                r.d.reg.a2 <= (others => '0');
              when BEQ =>
                r.d.dest <= (others => '0');
                r.d.data <= unsigned(resize(
                  signed(inst(13 downto 0)), 32));
                r.d.reg.a1 <= ra;
                r.d.reg.a2 <= rb;
              when others =>
                r.d <= default_d;
            end case;
          else --elsif r.e.branch = '1' then
            r.d <= default_d;
          end if;


          --execute
          r.e.op <= r.d.op;
          r.e.dest <= r.d.dest;
          case r.d.op is
            when ST =>
              r.e.alu.d1 <= reg_o.d2;
              r.e.alu.d2 <= r.d.data;
              r.e.alu.ctrl <= "000";
              r.e.branch <= '0';
              r.e.data <= reg_o.d1;
            when ADD =>
              r.e.alu.d1 <= reg_o.d1;
              r.e.alu.d2 <= reg_o.d2;
              r.e.alu.ctrl <= "000";
              r.e.branch <= '0';
            when ADDI =>
              r.e.alu.d1 <= reg_o.d1;
              r.e.alu.d2 <= r.d.data;
              r.e.alu.ctrl <= "000";
              r.e.branch <= '0';
            when BEQ =>
              r.e.alu.d1 <= resize(r.d.pc, 32);
              r.e.alu.d2 <= r.d.data;
              if reg_o.d1 = reg_o.d2 then
                r.e.branch <= '1';
              else
                r.e.branch <= '0';
              end if;
            when others =>
              r.e <= default_e;
          end case;


          --memory access
          r.m.op <= r.e.op;
          r.m.dest <= r.e.dest;
          case r.e.op is
            when ST =>
              r.mem.a <= alu_o.d(19 downto 0);
              r.mem.d <= r.e.data;
              r.mem.go <= '1';
              r.mem.we <= '1';
            when ADD =>
              r.m.data <= alu_o.d;
              r.mem <= default_mem_in;
            when ADDI =>
              r.m.data <= alu_o.d;
              r.mem <= default_mem_in;
            when BEQ =>
              r.m.data <= alu_o.d;
              r.mem <= default_mem_in;
            when others =>
              r.m <= default_m;
              r.mem <= default_mem_in;
          end case;


          -- write
          case r.m.op is
            when ADD | ADDI =>
              r.w.reg.we <= '1';
              r.w.reg.a <= r.m.dest;
              r.w.reg.d <= r.m.data;
            when BEQ =>
              r.w.reg.we <= '0';
            when others =>
              r.w.reg.we <= '0';
          end case;

        else
          r.mem <= default_mem_in;
        end if;

      else --setup
        r <= init_r;
        setup <= setup+1;
      end if;

    end if;

  end process;

end arch_control;
