library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.Util.all;

entity Memory is
  generic(
    wtime : std_logic_vector(15 downto 0) := x"1ADB");
  port (
    clk     : in    std_logic;
    RS_RX   : in    std_logic;
    RS_TX   : out   std_logic;
    ZD      : inout std_logic_vector(31 downto 0);
    ZA      : out   std_logic_vector(19 downto 0);
    XWA     : out   std_logic;
    bus_out : in    bus_out_t;
    bus_in  : out   bus_in_t);
end Memory;

architecture Memory_arch of Memory is

  component MemoryMappedIO is
    generic(
      wtime : std_logic_vector(15 downto 0) := wtime);
    port (
      clk     : in  std_logic;
      RS_RX   : in  std_logic;
      RS_TX   : out std_logic;
      request : in  memory_request_t;
      reply   : out memory_reply_t);
  end component;

  component CodeSegmentRAM is
    port (
      clk     : in  std_logic;
      bus_out : in  bus_out_t;
      bus_in  : out bus_in_t);
  end component;

  component MemoryCache is
    port (
      clk     : in    std_logic;
      ZD      : inout std_logic_vector(31 downto 0);
      ZA      : out   std_logic_vector(19 downto 0);
      XWA     : out   std_logic;
      request : in    memory_request_t;
      reply   : out   memory_reply_t);
  end component;

  type memory_t is record
    stall : std_logic;
    state : std_logic_vector(1 downto 0);
    buf : memory_request_t;
  end record;

  signal r : memory_t;
  signal stall : std_logic;
  signal request : memory_request_t;
  signal io_reply, cache_reply : memory_reply_t;
  signal code_bus_out : bus_out_t;
  signal code_bus_in : bus_in_t;

begin

  io_unit : MemoryMappedIO port map (
    clk => clk,
    RS_RX => RS_RX,
    RS_TX => RS_TX,
    request => request,
    reply => io_reply);

  code_unit : CodeSegmentRAM port map (
    clk => clk,
    bus_out => code_bus_out,
    bus_in => code_bus_in);

  cache_unit : MemoryCache port map (
    clk => clk,
    ZD => ZD,
    ZA => ZA,
    XWA => XWA,
    request => request,
    reply => cache_reply);

  process(clk)
    variable vreq : memory_request_t;
  begin
    if rising_edge(clk) then
      if r.stall = '0' then
        vreq := bus_out.m;
      else
        vreq := r.buf;
      end if;

      if stall = '0' then
        if vreq.go = '1' then
          if vreq.a = x"FFFFF" then
            r.state <= "01"; -- read io
          elsif vreq.a(19 downto ADDR_WIDTH) = ones(19 downto ADDR_WIDTH) then
            r.state <= "10"; -- read code(BRAM)
          else
            r.state <= "11"; -- read cache(SRAM)
          end if;
        else
          r.state <= "00";
        end if;

      end if;

      if stall = '1' and r.stall = '0' then
        r.buf <= bus_out.m;
      end if;

      r.stall <= stall;

    end if;
  end process;

  stall <= io_reply.stall when r.state = "01" else
           cache_reply.stall when r.state = "11" else
           '0';
  request <= r.buf when stall = '0' and r.stall = '1' else
             bus_out.m;
  code_bus_out.m <= request;
  code_bus_out.pc <= bus_out.pc;
  bus_in.i <= code_bus_in.i;
  bus_in.m.d <= io_reply.d when r.state = "01" else
                code_bus_in.m.d when r.state = "10" else
                cache_reply.d when r.state = "11" else
                (others => '-');
  bus_in.m.stall <= stall;

end Memory_arch;
