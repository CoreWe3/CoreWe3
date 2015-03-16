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
    ADVA    : out   std_logic;
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
      ADVA    : out   std_logic;
      request : in    memory_request_t;
      reply   : out   memory_reply_t);
  end component;

  type memory_t is record
    busy : std_logic;
    buf : memory_request_t;
  end record;

  signal r,s : memory_t;
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
    ADVA => ADVA,
    request => request,
    reply => cache_reply);

  process(r, bus_out, io_reply, cache_reply, code_bus_in)
    variable v :memory_t;
    variable vreq : memory_request_t;
  begin
    v := r;
    v.busy := io_reply.busy or cache_reply.busy;

    if v.busy = '1' then
      vreq := default_memory_request;
    elsif r.busy = '1' then
      vreq := r.buf;
    else
      vreq := bus_out.m;
    end if;

    if v.busy = '1' and r.busy = '0' then -- start stalling
      v.buf := bus_out.m;
    end if;

    request <= vreq;
    code_bus_out <= (bus_out.pc, vreq);
    bus_in.i <= code_bus_in.i;

    if io_reply.complete = '1' then
      bus_in.m.d <= io_reply.d;
      bus_in.m.complete <= '1';
    elsif code_bus_in.m.complete = '1' then
      bus_in.m.d <= code_bus_in.m.d;
      bus_in.m.complete <= '1';
    elsif cache_reply.complete = '1' then
      bus_in.m.d <= cache_reply.d;
      bus_in.m.complete <= '1';
    else
      bus_in.m.d <= (others => '-');
      bus_in.m.complete <= '0';
    end if;
    bus_in.m.busy <= v.busy;

    s <= v;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      r <= s;
    end if;
  end process;

end Memory_arch;
