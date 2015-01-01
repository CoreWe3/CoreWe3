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


  signal r : cpu_t := init_r;
  signal data_hazard : std_logic := '0';
  signal alu_o : alu_out_t;
  signal reg_o : reg_out_t;
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
                  r.d.data <= unsigned(resize(
                    signed(inst(19 downto 0)), 32));
                  r.d.a1 <= (others => '0');
                  r.d.a2 <= (others => '0');
                when ADD | SUB =>
                  r.d.dest <= unsigned(inst(25 downto 20));
                  r.d.data <= (others => '-');
                  r.d.a1 <= unsigned(inst(19 downto 14));
                  r.d.a2 <= unsigned(inst(13 downto 8));
                when ADDI =>
                  r.d.dest <= unsigned(inst(25 downto 20));
                  r.d.data <= unsigned(resize(
                    signed(inst(13 downto 0)), 32));
                  r.d.a1 <= unsigned(inst(19 downto 14));
                  r.d.a2 <= (others => '0');
                when BEQ =>
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
                when ST =>
                  r.e.alu.d1 <= reg_o.d2;
                  r.e.alu.d2 <= r.d.data;
                  r.e.alu.ctrl <= "000";
                  r.e.branch <= '0';
                  r.e.data <= reg_o.d1;
                when LDA | LDIH | LDIL =>
                  r.e.alu.d1 <= r.d.data;
                  r.e.alu.d2 <= (others => '0');
                  r.e.alu.ctrl <= "000";
                  r.e.branch <= '0';
                  r.e.data <= reg_o.d1;
                when STA =>
                  r.e.alu.d1 <= r.d.data;
                  r.e.alu.d2 <= (others => '0');
                  r.e.alu.ctrl <= "000";
                  r.e.branch <= '0';
                  r.e.data <= reg_o.d1;
                when ADD =>
                  r.e.alu.d1 <= reg_o.d1;
                  r.e.alu.d2 <= reg_o.d2;
                  r.e.alu.ctrl <= "000";
                  r.e.branch <= '0';
                  r.e.data <= (others => '-');
                when SUB =>
                  r.e.alu.d1 <= reg_o.d1;
                  r.e.alu.d2 <= reg_o.d2;
                  r.e.alu.ctrl <= "001";
                  r.e.branch <= '0';
                  r.e.data <= (others => '-');
                when ADDI =>
                  r.e.alu.d1 <= reg_o.d1;
                  r.e.alu.d2 <= r.d.data;
                  r.e.alu.ctrl <= "000";
                  r.e.branch <= '0';
                  r.e.data <= (others => '-');
                when BEQ =>
                  r.e.alu.d1 <= resize(r.d.pc, 32);
                  r.e.alu.d2 <= r.d.data;
                  r.e.alu.ctrl <= "000";
                  if reg_o.d1 = reg_o.d2 then
                    r.e.branch <= '1';
                  else
                    r.e.branch <= '0';
                  end if;
                  r.e.data <= (others => '-');
                when JSUB =>
                  r.e.alu.d1 <= resize(r.d.pc, 32);
                  r.e.alu.d2 <= r.d.data;
                  r.e.alu.ctrl <= "000";
                  r.e.branch <= '1';
                  r.e.data <= reg_o.d1;
                when RET =>
                  r.e.alu.d1 <= reg_o.d1;
                  r.e.alu.d2 <= (others => '0');
                  r.e.alu.ctrl <= "000";
                  r.e.branch <= '1';
                  r.e.data <= (others => '-');
                when PUSH =>
                  r.e.alu.d1 <= reg_o.d1;
                  r.e.alu.d2 <= (others => '0');
                  r.e.alu.ctrl <= "000";
                  r.e.branch <= '0';
                  r.e.data <= (others => '-');
                when POP =>
                  r.e.alu <= default_alu;
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
              when LDA =>
                r.mem.a <= alu_o.d(19 downto 0);
                r.mem.d <= (others => '-');
                r.mem.go <= '1';
                r.mem.we <= '0';
                r.m.data <= (others => '-');
              when LDIH =>
                r.m.data <= alu_o.d(15 downto 0) &
                            r.e.data(15 downto 0);
                r.mem <= default_mem_in;
              when LDIL | ADD | SUB | ADDI =>
                r.m.data <= alu_o.d;
                r.mem <= default_mem_in;
              when BEQ =>
                r.m.data <= (others => '-');
                r.mem <= default_mem_in;
              when JSUB =>
                r.mem.a <= r.sp-1;
                r.mem.d <= r.e.data;
                r.mem.go <= '1';
                r.mem.we <= '1';
                r.m.data <= resize(r.e.pc+1, 32);
                r.sp <= r.sp-1;
              when RET =>
                r.mem.a <= r.sp;
                r.mem.d <= (others => '-');
                r.mem.go <= '1';
                r.mem.we <= '0';
                r.m.data <= (others => '-');
                r.sp <= r.sp+1;
              when PUSH =>
                r.mem.a <= r.sp-1;
                r.mem.d <= alu_o.d;
                r.mem.go <= '1';
                r.mem.we <= '1';
                r.m.data <= (others => '-');
                r.sp <= r.sp-1;
              when POP =>
                r.mem.a <= r.sp;
                r.mem.d <= (others => '-');
                r.mem.go <= '1';
                r.mem.we <= '0';
                r.m.data <= (others => '-');
                r.sp <= r.sp+1;
              when others =>
                r.mem <= default_mem_in;
            end case;

            -- write
            case r.m.op is
              when LDA | LDIH | LDIL | ADD | SUB | ADDI |
                JSUB | RET | POP =>
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

          -- read memory
          case r.m.op is
            when LDA | POP | RET =>
              if r.mem.go = '0' and memo.busy = '0' then
                r.m.data <= memo.d;
                r.state <= '0';
              else
                r.m.data <= (others => '-');
              end if;
            when others =>
              r.state <= '0';
          end case;

          r.mem <= default_mem_in;

        end if;

      else --setup
        r <= init_r;
        setup <= setup+1;
      end if;

    end if;

  end process;

end arch_control;
