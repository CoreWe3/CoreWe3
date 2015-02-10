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
    variable da, db, dc : unsigned(31 downto 0);
    variable da_hazard, db_hazard, dc_hazard : std_logic;
    variable da_forward, db_forward, dc_forward : std_logic;
    variable data_hazard : std_logic;
    variable d_save, d_restore : decode_t;
  begin

    if rising_edge(clk) then

      ---forwarding
      if unsigned(instruction_mem_o(25 downto 21)) = r.d.dest and r.d.dest /= 0 then
        da := (others => '-');
        case r.d.op is
          when ADD | SUB | ADDI =>
            da_hazard := '0';
            da_forward := '1';
          when others =>
            da_hazard := '1';
            da_forward := '0';
        end case;
      elsif unsigned(instruction_mem_o(25 downto 21)) = r.e.dest and r.e.dest /= 0 then
        da_forward := '0';
        case r.e.op is
          when ADD | SUB | ADDI =>
            da_hazard := '0';
            da := alu_o.d;
          when others =>
            da_hazard := '1';
            da := (others => '-');
        end case;
      elsif unsigned(instruction_mem_o(25 downto 21)) = r.m.dest and r.m.dest /= 0 then
        da_forward := '0';
        case r.m.op is
          when ADD | SUB | ADDI =>
            da_hazard := '0';
            da := r.m.data;
          when others =>
            da_hazard := '1';
            da := (others => '-');
        end case;
      else
        da_hazard := '0';
        da_forward := '0';
        da := r.gpreg(to_integer(unsigned(instruction_mem_o(25 downto 21))));
      end if;

      if unsigned(instruction_mem_o(20 downto 16)) = r.d.dest and r.d.dest /= 0 then
        db := (others => '-');
        case r.d.op is
          when ADD | SUB | ADDI =>
            db_hazard := '0';
            db_forward := '1';
          when others =>
            db_hazard := '1';
            db_forward := '0';
        end case;
      elsif unsigned(instruction_mem_o(20 downto 16)) = r.e.dest and r.e.dest /= 0 then
        db_forward := '0';
        case r.e.op is
          when ADD | SUB | ADDI =>
            db_hazard := '0';
            db := alu_o.d;
          when others =>
            db_hazard := '1';
            db := (others => '-');
        end case;
      elsif unsigned(instruction_mem_o(20 downto 16)) = r.m.dest and r.m.dest /= 0 then
        db_forward := '0';
        case r.m.op is
          when ADD | SUB | ADDI =>
            db_hazard := '0';
            db := r.m.data;
          when others =>
            db_hazard := '1';
            db := (others => '-');
        end case;
      else
        db_hazard := '0';
        db_forward := '0';
        db := r.gpreg(to_integer(unsigned(instruction_mem_o(20 downto 16))));
      end if;

      if unsigned(instruction_mem_o(15 downto 11)) = r.d.dest and r.d.dest /= 0 then
        dc := (others => '-');
        case r.d.op is
          when ADD | SUB | ADDI =>
            dc_hazard := '0';
            dc_forward := '1';
          when others =>
            dc_hazard := '1';
            dc_forward := '0';
        end case;
      elsif unsigned(instruction_mem_o(15 downto 11)) = r.e.dest and r.e.dest /= 0 then
        dc_forward := '0';
        case r.e.op is
          when ADD | SUB | ADDI =>
            dc_hazard := '0';
            dc := alu_o.d;
          when others =>
            dc_hazard := '1';
            dc := (others => '-');
        end case;
      elsif unsigned(instruction_mem_o(15 downto 11)) = r.m.dest and r.m.dest /= 0 then
        dc_forward := '0';
        case r.m.op is
          when ADD | SUB | ADDI =>
            dc_hazard := '0';
            dc := r.m.data;
          when others =>
            dc_hazard := '1';
            dc := (others => '-');
        end case;
      else
        dc_hazard := '0';
        dc_forward := '0';
        dc := r.gpreg(to_integer(unsigned(instruction_mem_o(15 downto 11))));
      end if;

      --data_hazard detection
      case instruction_mem_o(31 downto 26) is
        when ST =>
          data_hazard := da_hazard or db_hazard;
        when ADD | SUB =>
          data_hazard := db_hazard or dc_hazard;
        when ADDI =>
          data_hazard := db_hazard;
        when others =>
          data_hazard := '0';
      end case;

      -- decode
      d_save.pc := r.f.pc;
      d_save.op := instruction_mem_o(31 downto 26);
      case instruction_mem_o(31 downto 26) is
        when LD | FLD =>
        when ST =>
          d_save.dest := (others => '0');
          d_save.d1 := da;
          d_save.d2 := db;
          d_save.data := unsigned(resize(
            signed(instruction_mem_o(15 downto 0)), 32));
          d_save.forward := da_forward & db_forward;
        when ADD | SUB | SH_L | SH_R | F_ADD | F_MUL =>
          d_save.dest := unsigned(instruction_mem_o(25 downto 21));
          d_save.d1 := db;
          d_save.d2 := dc;
          d_save.data := (others => '-');
          d_save.forward := db_forward & dc_forward;
        when ADDI | SHLI | SHRI | LDIH | FLDIL | FLDIH =>
          d_save.dest := unsigned(instruction_mem_o(25 downto 21));
          d_save.d1 := db;
          d_save.d2 := (others => '0');
          d_save.data := unsigned(resize(
            signed(instruction_mem_o(15 downto 0)), 32));
          d_save.forward := db_forward & '0';
        when F_INV | F_SQRT | F_ABS =>
        when FCMP =>
        when J | JEQ | JLE | JLT | JSUB =>
        when RET =>
        when others =>
      end case;

      if data_mem_o.busy = '0' then -- stall of memory

        r.state <= '0';

        if data_hazard = '0' then -- stall of data hazard

          --fetch
          r.f.pc <= r.f.pc+1;

          --decode
          if r.state = '0' then
            r.d <= d_save;
          else
            r.d <= r.d_backup;
          end if;

          --execute
          r.e.op <= r.d.op;
          r.e.dest <= r.d.dest;
          r.e.pc <= r.d.pc;
          case r.d.op is
            when LD | FLD =>
            when ST | FST =>
              if r.d.forward(0) = '0' then
                r.e.alu.d1 <= r.d.d2;
              else
                r.e.alu.d1 <= alu_o.d;
              end if;
              r.e.alu.d2 <= r.d.data;
              r.e.alu.ctrl <= "00";
              r.e.fpu <= default_fpu_in;
              if r.d.forward(1) = '0' then
                r.e.data <= r.d.d1;
              else
                r.e.data <= alu_o.d;
              end if;
            when ITOF =>
            when FTOI =>
            when ADD =>
              if r.d.forward(1) = '0' then
                r.e.alu.d1 <= r.d.d1;
              else
                r.e.alu.d1 <= alu_o.d;
              end if;
              if r.d.forward(0) = '0' then
                r.e.alu.d2 <= r.d.d2;
              else
                r.e.alu.d2 <= alu_o.d;
              end if;
              r.e.alu.ctrl <= "00";
              r.e.fpu <= default_fpu_in;
              r.e.data <= (others => '-');
            when SUB =>
              if r.d.forward(1) = '0' then
                r.e.alu.d1 <= r.d.d1;
              else
                r.e.alu.d1 <= alu_o.d;
              end if;
              if r.d.forward(0) = '0' then
                r.e.alu.d2 <= r.d.d2;
              else
                r.e.alu.d2 <= alu_o.d;
              end if;
              r.e.alu.ctrl <= "01";
              r.e.fpu <= default_fpu_in;
              r.e.data <= (others => '-');
            when ADDI =>
              if r.d.forward(1) = '0' then
                r.e.alu.d1 <= r.d.d1;
              else
                r.e.alu.d1 <= alu_o.d;
              end if;
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

        else -- data hazard

          r.e <= default_e;

        end if;

        -- memory
        r.m.op <= r.e.op;
        r.m.dest <= r.e.dest;
        case r.e.op is
          when ST | FST =>
            r.m.data <= (others => '-');
            r.m.mem.a <= alu_o.d(19 downto 0);
            r.m.mem.d <= r.e.data;
            r.m.mem.go <= '1';
            r.m.mem.we <= '1';
          when ADD | SUB | ADDI =>
            r.m.data <= alu_o.d;
            r.m.mem <= default_mem_in;
          when others =>
        end case;

        -- write
        case r.m.op is
          when LD | FLD | LDIH | FTOI | ADD | SUB | ADDI |
            SH_L | SH_R | SHLI | SHRI | JSUB =>
            r.gpreg(to_integer(r.m.dest)) <= r.m.data;
          when others =>
        end case;

      else -- stalling

        r.state <= '1';

        if r.state = '0' then
          r.d_backup <= d_save;
        end if;

        r.m.mem <= default_mem_in;

      end if;

    end if;

  end process;

end Control_arch;
