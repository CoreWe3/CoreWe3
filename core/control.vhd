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

  component detect_hazard is
    port (
      inst  : in std_logic_vector(31 downto 0);
      dest1 : in unsigned(5 downto 0);
      dest2 : in unsigned(5 downto 0);
      dest3 : in unsigned(5 downto 0);
      data_hazard : out std_logic);
  end component;


  signal r : cpu_t := init_r;
  signal data_hazard : std_logic;
  signal alu_o : alu_out_t;
  signal reg_o : reg_out_t;
  signal setup : unsigned(1 downto 0) := (others => '0');

begin
  pc <= r.f.pc;
  memi <= r.mem;

  reg : registers port map (
    clk => clk,
    rdi => r.d.reg,
    wdi => r.w.reg,
    do => reg_o);

  alu0 : alu port map (
    di => r.e.alu,
    do => alu_o);

  detect_hazard0 : detect_hazard port map (
    inst => inst,
    dest1 => r.d.dest,
    dest2 => r.e.dest,
    dest3 => r.m.dest,
    data_hazard => data_hazard);

  main : process(clk)
    variable v : cpu_t;
    variable mem_stall : std_logic;
  begin
    if rising_edge(clk) then

      --ready
      if setup = 3 then

        --stall for memory access
        if r.mem.go = '0' and memo.busy = '0' then


          --fetch
          if r.e.branch = '1' then
            r.f.pc <= alu_o.d(ADDR_WIDTH-1 downto 0);
          else
            if data_hazard = '0' then
              r.f.pc <= r.f.pc+1;
            end if;
          end if;

          --decode
          if r.e.branch = '1' then
            r.d <= default_d;
          else
            if data_hazard = '0' then
              r.d.pc <= r.f.pc;
              r.d.op <= inst(31 downto 26);
              case inst(31 downto 26) is
                when ST =>
                  r.d.dest <= (others => '0');
                  r.d.data <= unsigned(resize(
                    signed(inst(13 downto 0)), 32));
                  r.d.reg.a1 <= unsigned(inst(25 downto 20));
                  r.d.reg.a2 <= unsigned(inst(19 downto 14));
                when ADD =>
                  r.d.dest <= unsigned(inst(25 downto 20));
                  r.d.data <= (others => '0');
                  r.d.reg.a1 <= unsigned(inst(19 downto 14));
                  r.d.reg.a2 <= unsigned(inst(13 downto 8));
                when ADDI =>
                  r.d.dest <= unsigned(inst(25 downto 20));
                  r.d.data <= unsigned(resize(
                    signed(inst(13 downto 0)), 32));
                  r.d.reg.a1 <= unsigned(inst(19 downto 14));
                  r.d.reg.a2 <= (others => '0');
                when BEQ =>
                  r.d.dest <= (others => '0');
                  r.d.data <= unsigned(resize(
                    signed(inst(13 downto 0)), 32));
                  r.d.reg.a1 <= unsigned(inst(25 downto 20));
                  r.d.reg.a2 <= unsigned(inst(19 downto 14));
                when others =>
                  r.d <= default_d;
              end case;
            else
              r.d <= default_d;
            end if;
          end if;


          --execute
          if r.e.branch = '1' then
            r.e <= default_e;
          else
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

          end if;

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
