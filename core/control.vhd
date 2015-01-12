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
    ready : in std_logic;
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
      di : in reg_in_t;
      do : out reg_out_t);
  end component;

  component detect_hazard is
    port (
      a1 : in unsigned(5 downto 0);
      a2 : in unsigned(5 downto 0);
      dest1 : in unsigned(5 downto 0);
      dest2 : in unsigned(5 downto 0);
      data_hazard : out std_logic);
  end component;

  component fadd is
    port (
      clk : in std_logic;
      a   : in  std_logic_vector(31 downto 0);
      b   : in  std_logic_vector(31 downto 0);
      o   : out std_logic_vector(31 downto 0));
  end component;

  component fmul is
    port (
      clk : in std_logic;
      a : in  std_logic_vector(31 downto 0);
      b : in  std_logic_vector(31 downto 0);
      o : out std_logic_vector(31 downto 0));
  end component;


  signal r : cpu_t := init_r;
  signal data_hazard : std_logic := '0';
  signal alu_o : alu_out_t;
  signal reg_o : reg_out_t;
  signal fadd_o : std_logic_vector(31 downto 0);
  signal fmul_o : std_logic_vector(31 downto 0);
  signal setup : unsigned(1 downto 0) := (others => '0');

begin
  pc <= r.f.pc;
  memi <= r.mem;

  reg : registers port map (
    clk => clk,
    di => r.reg,
    do => reg_o);

  alu0 : alu port map (
    di => r.e.alu,
    do => alu_o);

  detect_hazard0 : detect_hazard port map (
    a1 => r.d.a1,
    a2 => r.d.a2,
    dest1 => r.e.dest,
    dest2 => r.m.dest,
    data_hazard => data_hazard);

  fadd0 : fadd port map (
    clk => clk,
    a => std_logic_vector(r.e.fpu.d1),
    b => std_logic_vector(r.e.fpu.d2),
    o => fadd_o);

  fmul0 : fmul port map (
    clk => clk,
    a => std_logic_vector(r.e.fpu.d1),
    b => std_logic_vector(r.e.fpu.d2),
    o => fmul_o);

  main : process(clk)
  begin
    if rising_edge(clk) then

      --ready
      if setup = 3 then

        if r.state = '0' then -- first

          r.state <= '1';

          --stall for memory access
          if memo.busy = '0' then


            --fetch
            if data_hazard = '0' then
              r.f.pc <= r.f.pc+1;
            end if;


            --decode
            if data_hazard = '0' then
              r.d.pc <= r.f.pc;
              r.d.op <= inst(31 downto 26);
              case inst(31 downto 26) is
                when LD =>
                  r.d.dest <= unsigned(inst(25 downto 20));
                  r.d.data <= unsigned(resize(
                    signed(inst(13 downto 0)), 32));
                  r.d.a1 <= unsigned(inst(19 downto 14));
                  r.d.a2 <= (others => '0');
                when ST =>
                  r.d.dest <= (others => '0');
                  r.d.data <= unsigned(resize(
                    signed(inst(13 downto 0)), 32));
                  r.d.a1 <= unsigned(inst(25 downto 20));
                  r.d.a2 <= unsigned(inst(19 downto 14));
                when LDA =>
                  r.d.dest <= unsigned(inst(25 downto 20));
                  r.d.data <= unsigned(resize(
                    signed(inst(19 downto 0)), 32));
                  r.d.a1 <= (others => '0');
                  r.d.a2 <= (others => '0');
                when STA =>
                  r.d.dest <= (others => '0');
                  r.d.data <= unsigned(resize(
                    signed(inst(19 downto 0)), 32));
                  r.d.a1 <= unsigned(inst(25 downto 20));
                  r.d.a2 <= (others => '0');
                when LDIH =>
                  r.d.dest <= unsigned(inst(25 downto 20));
                  r.d.data <= unsigned(resize(
                    signed(inst(15 downto 0)), 32));
                  r.d.a1 <= unsigned(inst(25 downto 20));
                  r.d.a2 <= (others => '0');
                when LDIL =>
                  r.d.dest <= unsigned(inst(25 downto 20));
                  r.d.data <= resize(unsigned(inst(19 downto 0)), 32);
                  r.d.a1 <= (others => '0');
                  r.d.a2 <= (others => '0');
                when ADD | SUB | A_ND | O_R | X_OR |
                  S_HL | S_HR | F_ADD | F_MUL =>
                  r.d.dest <= unsigned(inst(25 downto 20));
                  r.d.data <= (others => '-');
                  r.d.a1 <= unsigned(inst(19 downto 14));
                  r.d.a2 <= unsigned(inst(13 downto 8));
                when FNEG =>
                  r.d.dest <= unsigned(inst(25 downto 20));
                  r.d.data <= (others => '-');
                  r.d.a1 <= unsigned(inst(19 downto 14));
                  r.d.a2 <= (others => '0');
                when ADDI | SHLI | SHRI =>
                  r.d.dest <= unsigned(inst(25 downto 20));
                  r.d.data <= unsigned(resize(
                    signed(inst(13 downto 0)), 32));
                  r.d.a1 <= unsigned(inst(19 downto 14));
                  r.d.a2 <= (others => '0');
                when BEQ | BLE | BLT | BFLE =>
                  r.d.dest <= (others => '0');
                  r.d.data <= unsigned(resize(
                    signed(inst(13 downto 0)), 32));
                  r.d.a1 <= unsigned(inst(25 downto 20));
                  r.d.a2 <= unsigned(inst(19 downto 14));
                when JSUB =>
                  r.d.dest <= "111111";
                  r.d.data <= unsigned(resize(
                    signed(inst(25 downto 0)), 32));
                  r.d.a1 <= "111111";
                  r.d.a2 <= (others => '0');
                when RET =>
                  r.d.dest <= "111111";
                  r.d.data <= (others => '-');
                  r.d.a1 <= "111111";
                  r.d.a2 <= (others => '0');
                when PUSH =>
                  r.d.dest <= (others => '0');
                  r.d.data <= (others => '-');
                  r.d.a1 <= unsigned(inst(25 downto 20));
                  r.d.a2 <= (others => '0');
                when POP =>
                  r.d.dest <= unsigned(inst(25 downto 20));
                  r.d.data <= (others => '-');
                  r.d.a1 <= (others => '0');
                  r.d.a2 <= (others => '0');
                when others =>
              end case;
            end if;


            --execute
            if data_hazard = '0' then
              r.e.op <= r.d.op;
              r.e.dest <= r.d.dest;
              r.e.pc <= r.d.pc;
              case r.d.op is
                when LD =>
                  r.e.alu.d1 <= reg_o.d1;
                  r.e.alu.d2 <= r.d.data;
                  r.e.alu.ctrl <= "000";
                  r.e.fpu <= default_fpu_in;
                  r.e.branch <= '0';
                  r.e.data <= (others => '-');
                when ST =>
                  r.e.alu.d1 <= reg_o.d2;
                  r.e.alu.d2 <= r.d.data;
                  r.e.alu.ctrl <= "000";
                  r.e.fpu <= default_fpu_in;
                  r.e.branch <= '0';
                  r.e.data <= reg_o.d1;
                when LDA | LDIH | LDIL =>
                  r.e.alu.d1 <= r.d.data;
                  r.e.alu.d2 <= (others => '0');
                  r.e.alu.ctrl <= "000";
                  r.e.fpu <= default_fpu_in;
                  r.e.branch <= '0';
                  r.e.data <= reg_o.d1;
                when STA =>
                  r.e.alu.d1 <= r.d.data;
                  r.e.alu.d2 <= (others => '0');
                  r.e.alu.ctrl <= "000";
                  r.e.fpu <= default_fpu_in;
                  r.e.branch <= '0';
                  r.e.data <= reg_o.d1;
                when ADD =>
                  r.e.alu.d1 <= reg_o.d1;
                  r.e.alu.d2 <= reg_o.d2;
                  r.e.alu.ctrl <= "000";
                  r.e.fpu <= default_fpu_in;
                  r.e.branch <= '0';
                  r.e.data <= (others => '-');
                when SUB =>
                  r.e.alu.d1 <= reg_o.d1;
                  r.e.alu.d2 <= reg_o.d2;
                  r.e.alu.ctrl <= "001";
                  r.e.fpu <= default_fpu_in;
                  r.e.branch <= '0';
                  r.e.data <= (others => '-');
                when FNEG =>
                  r.e.alu.d1 <= reg_o.d1;
                  r.e.alu.d2 <= x"80000000";
                  r.e.alu.ctrl <= "100";
                  r.e.fpu <= default_fpu_in;
                  r.e.branch <= '0';
                  r.e.data <= (others => '-');
                when ADDI =>
                  r.e.alu.d1 <= reg_o.d1;
                  r.e.alu.d2 <= r.d.data;
                  r.e.alu.ctrl <= "000";
                  r.e.fpu <= default_fpu_in;
                  r.e.branch <= '0';
                  r.e.data <= (others => '-');
                when A_ND =>
                  r.e.alu.d1 <= reg_o.d1;
                  r.e.alu.d2 <= reg_o.d2;
                  r.e.alu.ctrl <= "010";
                  r.e.fpu <= default_fpu_in;
                  r.e.branch <= '0';
                  r.e.data <= (others => '-');
                when O_R =>
                  r.e.alu.d1 <= reg_o.d1;
                  r.e.alu.d2 <= reg_o.d2;
                  r.e.alu.ctrl <= "011";
                  r.e.fpu <= default_fpu_in;
                  r.e.branch <= '0';
                  r.e.data <= (others => '-');
                when X_OR =>
                  r.e.alu.d1 <= reg_o.d1;
                  r.e.alu.d2 <= reg_o.d2;
                  r.e.alu.ctrl <= "100";
                  r.e.fpu <= default_fpu_in;
                  r.e.branch <= '0';
                  r.e.data <= (others => '-');
                when S_HL =>
                  r.e.alu.d1 <= reg_o.d1;
                  r.e.alu.d2 <= reg_o.d2;
                  r.e.alu.ctrl <= "101";
                  r.e.fpu <= default_fpu_in;
                  r.e.branch <= '0';
                  r.e.data <= (others => '-');
                when S_HR =>
                  r.e.alu.d1 <= reg_o.d1;
                  r.e.alu.d2 <= reg_o.d2;
                  r.e.alu.ctrl <= "110";
                  r.e.fpu <= default_fpu_in;
                  r.e.branch <= '0';
                  r.e.data <= (others => '-');
                when SHLI =>
                  r.e.alu.d1 <= reg_o.d1;
                  r.e.alu.d2 <= r.d.data;
                  r.e.alu.ctrl <= "101";
                  r.e.fpu <= default_fpu_in;
                  r.e.branch <= '0';
                  r.e.data <= (others => '-');
                when SHRI =>
                  r.e.alu.d1 <= reg_o.d1;
                  r.e.alu.d2 <= r.d.data;
                  r.e.alu.ctrl <= "110";
                  r.e.fpu <= default_fpu_in;
                  r.e.branch <= '0';
                  r.e.data <= (others => '-');
                when BEQ =>
                  r.e.alu.d1 <= resize(r.d.pc, 32);
                  r.e.alu.d2 <= r.d.data;
                  r.e.alu.ctrl <= "000";
                  r.e.fpu <= default_fpu_in;
                  if reg_o.d1 = reg_o.d2 then
                    r.e.branch <= '1';
                  else
                    r.e.branch <= '0';
                  end if;
                  r.e.data <= (others => '-');
                when BLE =>
                  r.e.alu.d1 <= resize(r.d.pc, 32);
                  r.e.alu.d2 <= r.d.data;
                  r.e.alu.ctrl <= "000";
                  r.e.fpu <= default_fpu_in;
                  if reg_o.d1 <= reg_o.d2 then
                    r.e.branch <= '1';
                  else
                    r.e.branch <= '0';
                  end if;
                  r.e.data <= (others => '-');
                when BLT =>
                  r.e.alu.d1 <= resize(r.d.pc, 32);
                  r.e.alu.d2 <= r.d.data;
                  r.e.alu.ctrl <= "000";
                  r.e.fpu <= default_fpu_in;
                  if reg_o.d1 < reg_o.d2 then
                    r.e.branch <= '1';
                  else
                    r.e.branch <= '0';
                  end if;
                  r.e.data <= (others => '-');
                when BFLE =>
                  r.e.alu.d1 <= resize(r.d.pc, 32);
                  r.e.alu.d2 <= r.d.data;
                  r.e.alu.ctrl <= "000";
                  r.e.fpu <= default_fpu_in;
                  if signed(reg_o.d1) < signed(reg_o.d2) then
                    if reg_o.d1(31) = '1' and reg_o.d2(31) = '1' then
                      r.e.branch <= '0';
                    else
                      r.e.branch <= '1';
                    end if;
                  else
                    if reg_o.d1(31) = '1' and reg_o.d2(31) = '1' then
                      r.e.branch <= '1';
                    else
                      r.e.branch <= '0';
                    end if;
                  end if;
                  r.e.data <= (others => '-');
                when JSUB =>
                  r.e.alu.d1 <= resize(r.d.pc, 32);
                  r.e.alu.d2 <= r.d.data;
                  r.e.alu.ctrl <= "000";
                  r.e.fpu <= default_fpu_in;
                  r.e.branch <= '1';
                  r.e.data <= reg_o.d1;
                when RET =>
                  r.e.alu.d1 <= reg_o.d1;
                  r.e.alu.d2 <= (others => '0');
                  r.e.alu.ctrl <= "000";
                  r.e.fpu <= default_fpu_in;
                  r.e.branch <= '1';
                  r.e.data <= (others => '-');
                when PUSH =>
                  r.e.alu.d1 <= reg_o.d1;
                  r.e.alu.d2 <= (others => '0');
                  r.e.alu.ctrl <= "000";
                  r.e.fpu <= default_fpu_in;
                  r.e.branch <= '0';
                  r.e.data <= (others => '-');
                when POP =>
                  r.e.alu <= default_alu;
                  r.e.fpu <= default_fpu_in;
                  r.e.branch <= '0';
                  r.e.data <= (others => '-');
                when F_ADD | F_MUL =>
                  r.e.alu <= default_alu;
                  r.e.fpu.d1 <= reg_o.d1;
                  r.e.fpu.d2 <= reg_o.d2;
                  r.e.branch <= '0';
                  r.e.data <= (others => '-');
                when others =>
              end case;
            else
              r.e <= default_e;
            end if;

            --memory access
            r.m.op <= r.e.op;
            r.m.dest <= r.e.dest;
            case r.e.op is
              when ST | STA =>
                r.mem.a <= alu_o.d(19 downto 0);
                r.mem.d <= r.e.data;
                r.mem.go <= '1';
                r.mem.we <= '1';
                r.m.data <= (others => '-');
                r.m.comp <= '-';
              when LD | LDA =>
                r.mem.a <= alu_o.d(19 downto 0);
                r.mem.d <= (others => '-');
                r.mem.go <= '1';
                r.mem.we <= '0';
                r.m.data <= (others => '-');
                r.m.comp <= '-';
              when LDIH =>
                r.m.data <= alu_o.d(15 downto 0) &
                            r.e.data(15 downto 0);
                r.mem <= default_mem_in;
                r.m.comp <= '-';
              when LDIL | ADD | SUB | FNEG | ADDI | A_ND | O_R |
                X_OR | S_HL | S_HR | SHLI | SHRI =>
                r.m.data <= alu_o.d;
                r.mem <= default_mem_in;
                r.m.comp <= '-';
              when BEQ | BLE | BLT | BFLE =>
                r.m.data <= (others => '-');
                r.mem <= default_mem_in;
                r.m.comp <= '-';
              when JSUB =>
                r.mem.a <= r.sp-1;
                r.mem.d <= r.e.data;
                r.mem.go <= '1';
                r.mem.we <= '1';
                r.m.data <= resize(r.e.pc+1, 32);
                r.sp <= r.sp-1;
                r.m.comp <= '-';
              when RET =>
                r.mem.a <= r.sp;
                r.mem.d <= (others => '-');
                r.mem.go <= '1';
                r.mem.we <= '0';
                r.m.data <= (others => '-');
                r.sp <= r.sp+1;
                r.m.comp <= '-';
              when PUSH =>
                r.mem.a <= r.sp-1;
                r.mem.d <= alu_o.d;
                r.mem.go <= '1';
                r.mem.we <= '1';
                r.m.data <= (others => '-');
                r.sp <= r.sp-1;
                r.m.comp <= '-';
              when POP =>
                r.mem.a <= r.sp;
                r.mem.d <= (others => '-');
                r.mem.go <= '1';
                r.mem.we <= '0';
                r.m.data <= (others => '-');
                r.sp <= r.sp+1;
                r.m.comp <= '-';
              when F_ADD | F_MUL =>
                r.mem <= default_mem_in;
                r.m.data <= (others => '-');
                r.m.comp <= '0';
              when others =>
                r.mem <= default_mem_in;
                r.m.data <= (others => '-');
                r.m.comp <= '-';
            end case;

            -- write
            case r.m.op is
              when LD | LDA | LDIH | LDIL | ADD | SUB | FNEG |
                A_ND | O_R | X_OR | S_HL | S_HR | SHLI | SHRI |
                ADDI | JSUB | RET | POP | F_ADD | F_MUL =>
                r.reg.we <= '1';
                r.reg.a1 <= r.m.dest;
                r.reg.d <= r.m.data;
              when others =>
                r.reg <= default_reg_in;
            end case;

          else
            r.mem <= default_mem_in;
          end if;

        else --latter

          -- branch hazard
          if r.e.branch = '1' then
            r.f.pc <= alu_o.d(ADDR_WIDTH-1 downto 0);
            r.d <= default_d;
          end if;

          -- read register
          r.reg.we <= '0';
          r.reg.a1 <= r.d.a1;
          r.reg.a2 <= r.d.a2;

          -- read memory and fpu
          case r.m.op is
            when LD | LDA | POP | RET =>
              if r.mem.go = '0' and memo.busy = '0' then
                r.m.data <= memo.d;
                r.state <= '0';
                r.m.comp <= '-';
              else
                r.m.data <= (others => '-');
                r.m.comp <= '-';
              end if;
            when F_ADD =>
              if r.m.comp = '1' then
                r.m.data <= unsigned(fadd_o);
                r.state <= '0';
                r.m.comp <= '-';
              else
                r.m.comp <= '1';
              end if;
            when F_MUL =>
              if r.m.comp = '1' then
                r.m.data <= unsigned(fmul_o);
                r.state <= '0';
                r.m.comp <= '-';
              else
                r.m.comp <= '1';
              end if;
            when others =>
              r.state <= '0';
          end case;

          r.mem <= default_mem_in;

        end if;

      else --setup
        r <= init_r;
        if ready = '1' then
          setup <= setup+1;
        end if;
        if setup = 1 then
          r.mem.a <= x"FFFFF";
          r.mem.d <= x"0000000a";
          r.mem.go <= '1';
          r.mem.we <= '1';
        else
          r <= init_r;
        end if;

      end if;

    end if;

  end process;

end arch_control;
