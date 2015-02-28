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
    request => request,
    reply => cache_reply);

  process(r, bus_out, io_reply, cache_reply, code_bus_in)
    variable v :memory_t;
    variable vreq : memory_request_t;
  begin
    v := r;
    if r.stall = '0' then
      vreq := bus_out.m;
    else
      vreq := r.buf;
    end if;

    case r.state is
      when "01" =>
        v.stall := io_reply.stall;
      when "11" =>
        v.stall := cache_reply.stall;
      when others =>
        v.stall := '0';
    end case;

    if v.stall = '0' then
      if vreq.go = '1' then
        if vreq.a = x"FFFFF" then
          v.state := "01"; -- read io
        elsif vreq.a(19 downto ADDR_WIDTH) = ones(19 downto ADDR_WIDTH) then
          v.state := "10"; -- read code(BRAM)
        else
          v.state := "11"; -- read cache(SRAM)
        end if;
      else
        v.state := "00";
      end if;
    end if;

    if v.stall = '1' and r.stall = '0' then -- start stalling
      v.buf := bus_out.m;
    end if;

    if v.stall = '0' and r.stall = '1' then -- finish stalling
      vreq := r.buf;
    else
      vreq := bus_out.m;
    end if;

    request <= vreq;
    bus_in.i <= code_bus_in.i;
    code_bus_out <= (bus_out.pc, vreq);

    case r.state is
      when "01" =>
        bus_in.m <= io_reply;
      when "10" =>
        bus_in.m <= code_bus_in.m;
      when "11" =>
        bus_in.m <= cache_reply;
      when others =>
        bus_in.m <= ((others => '-'), '0');
    end case;

    s <= v;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      r <= s;
    end if;
  end process;

end Memory_arch;
