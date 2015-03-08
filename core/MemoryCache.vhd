library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Util.all;

entity MemoryCache is
  port (
    clk : in std_logic;
    ZD : inout std_logic_vector(31 downto 0);
    ZA : out std_logic_vector(19 downto 0);
    XWA : out std_logic;
    request : in memory_request_t;
    reply : out memory_reply_t);
end MemoryCache;

architecture MemoryCache_arch of MemoryCache is

  type cache_t is array (2**CACHE_WIDTH-1 downto 0) of
    unsigned(31 downto 0);

  type tag_t is array (2**CACHE_WIDTH-1 downto 0) of
    unsigned(20 downto CACHE_WIDTH);

  type memory_cache_t is record
    buf1 : memory_request_t;
    buf2 : memory_request_t;
    stall : unsigned(1 downto 0);
    data : unsigned(31 downto 0);
    we : std_logic;
    ZD_buf : unsigned(31 downto 0);
  end record;

  signal cache : cache_t;
  signal tag : tag_t;
  signal r : memory_cache_t;

begin
  ZA <= std_logic_vector(request.a);
  XWA <= not request.we;
  ZD <= std_logic_vector(r.data) when r.we = '1' else
        (others => 'Z');

  process(clk)
    variable vreq1, vreq2 : memory_request_t;
    variable tagd : unsigned(20 downto CACHE_WIDTH);
    variable data : unsigned(31 downto 0);
    variable we : std_logic;
    variable stall : std_logic;
  begin
    if rising_edge(clk) then
      data := (others => '-');
      we := '0';
      stall := '0';

      if r.stall = "00" then
        vreq1 := request;
        vreq2 := r.buf1;
      else
        vreq1 := r.buf1;
        vreq2 := r.buf2;
      end if;

      case r.stall is
        when "00" =>
          if vreq1.go = '1' and
            vreq1.a(19 downto ADDR_WIDTH) /= ones(19 downto ADDR_WIDTH) then
            if vreq1.we = '1' then
              cache(to_integer(vreq1.a(CACHE_WIDTH-1 downto 0))) <= vreq1.d;
              tag(to_integer(vreq1.a(CACHE_WIDTH-1 downto 0))) <=
                '1' & vreq1.a(19 downto CACHE_WIDTH);
            end if;
            tagd := tag(to_integer(vreq1.a(CACHE_WIDTH-1 downto 0)));
            if tagd(20) = '1' and
              tagd(19 downto CACHE_WIDTH) = vreq1.a(19 downto CACHE_WIDTH) then
              reply.d <= cache(to_integer(vreq1.a(CACHE_WIDTH-1 downto 0)));
            else
              reply.d <= (others => '-');
              if vreq1.we = '0' then
                stall := '1';
              end if;
            end if;
          end if;

          if vreq2.go = '1' and vreq2.we = '1' and
            vreq2.a(19 downto 12) /= ones(19 downto ADDR_WIDTH) then
            data := vreq2.d;
            we := '1';
          end if;
        when "01" =>
          reply.d <= (others => '-');
          stall := '1';
        when "10" =>
          reply.d <= (others => '-');
          stall := '1';
        when "11" =>
          reply.d <= r.ZD_buf;
        when others =>
          reply.d <= (others => '-');
      end case;

      if stall = '0' then
        r.buf1 <= vreq1;
        r.buf2 <= vreq2;
        r.stall <= "00";
      else
        r.stall <= r.stall+1;
      end if;

      reply.stall <= stall;
      r.data <= data;
      r.we <= we;
      r.ZD_buf <= unsigned(ZD);
    end if;
  end process;

end MemoryCache_arch;
