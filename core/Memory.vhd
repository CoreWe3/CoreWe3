library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.Util.all;

entity Memory is
  generic(
    wtime : std_logic_vector(15 downto 0) := x"1ADB");
  port (
    clk   : in    std_logic;
    RS_RX : in    std_logic;
    RS_TX : out   std_logic;
    ZD    : inout std_logic_vector(31 downto 0);
    ZA    : out   std_logic_vector(19 downto 0);
    XWA   : out   std_logic;
    mem_i : in    mem_in_t;
    mem_o : out   mem_out_t);
end Memory;

architecture Memory_arch of Memory is

  component MemoryMappedIO is
    generic(
      wtime : std_logic_vector(15 downto 0) := wtime);
    port (
      clk   : in    std_logic;
      RS_RX : in    std_logic;
      RS_TX : out   std_logic;
      mem_i : in    mem_in_t;
      mem_o : out   mem_out_t);
  end component;

  component CodeSegmentRAM is
    generic (
      file_name : string := "file/loopback.b");
    port (
      clk : in std_logic;
      mem_i : in mem_in_t;
      mem_o : out mem_out_t);
  end component;

  type memory_t is record
    stall : std_logic;
    state : std_logic_vector(1 downto 0);
    buf : mem_in_t;
  end record;

  signal r : memory_t;
  signal stall : std_logic;
  signal mem_i_sel : mem_in_t;
  signal io_mem_o, code_mem_o, cache_mem_o : mem_out_t;

begin

  io_unit : MemoryMappedIO port map (
    clk => clk,
    RS_RX => RS_RX,
    RS_TX => RS_TX,
    mem_i => mem_i_sel,
    mem_o => io_mem_o);

  code_unit : CodeSegmentRAM port map (
    clk => clk,
    mem_i => mem_i_sel,
    mem_o => code_mem_o);

  process(clk)
    variable vmem_i : mem_in_t;
  begin
    if rising_edge(clk) then
      if r.stall = '0' then
        vmem_i := mem_i;
      else
        vmem_i := r.buf;
      end if;

      if stall = '0' then
        if vmem_i.m.go = '1' and vmem_i.m.we = '0' then
          if vmem_i.m.a = x"FFFFF" then
            r.state <= "01"; -- read io
          elsif vmem_i.m.a(19 downto 12) = x"FF" and
            vmem_i.m.a(11 downto 0) /= x"FFF" then
            r.state <= "10"; -- read code(BRAM)
          else
            r.state <= "11"; -- read cache(SRAM)
          end if;
        else
          r.state <= "00";
        end if;

      end if;

      if stall = '1' and r.stall = '0' then
        r.buf <= mem_i;
      end if;

      r.stall <= stall;

    end if;
  end process;

  stall <= io_mem_o.stall;
  mem_i_sel.m <= r.buf.m when stall = '0' and r.stall = '1' else
                 mem_i.m;
  mem_i_sel.pc <= mem_i.pc;
  mem_o.i <= code_mem_o.i;
  mem_o.d <= io_mem_o.d when r.state = "01" else
             code_mem_o.d when r.state = "10" else
             (others => '-');
  mem_o.stall <= stall;

end Memory_arch;
