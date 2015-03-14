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
    req1 : memory_request_t;
    req2 : memory_request_t;
    state : unsigned(1 downto 0);
    data : unsigned(31 downto 0);
    we : std_logic;
    ZD : unsigned(31 downto 0);
  end record;

  impure function init_tag(dummy : in std_logic) return tag_t is
    variable tag : tag_t;
  begin
    for i in tag_t'range loop
      tag(i) := (others => '0');
    end loop;
    return tag;
  end function;

  signal cache : cache_t;
  signal tag : tag_t := init_tag('0');
  signal r : memory_cache_t := (default_memory_request,
                                default_memory_request,
                                "00",
                                (others => '-'),
                                '0',
                                (others => '-'));

begin
  ZA <= std_logic_vector(request.a);
  XWA <= not request.we;
  ZD <= std_logic_vector(r.data) when r.we = '1' else
        (others => 'Z');

  process(clk)
    variable v : memory_cache_t;
    variable tagd : unsigned(20 downto CACHE_WIDTH);
    variable vrep : memory_reply_t;
    variable vZD : unsigned(31 downto 0);
  begin
    if rising_edge(clk) then
      v := r;
      v.data := (others => '-');
      v.we := '0';
      vrep := ((others => '-'), '0', '0');
      v.ZD := unsigned(ZD);

      if r.state = "00" then
        v.req1 := request;
        v.req2 := r.req1;
      else
        v.req1 := r.req1;
        v.req2 := r.req2;
      end if;

      case r.state is
        when "00" =>
          if v.req1.go = '1' and
            v.req1.a(19 downto ADDR_WIDTH) /= ones(19 downto ADDR_WIDTH) then
            tagd := tag(to_integer(v.req1.a(CACHE_WIDTH-1 downto 0)));
            if v.req1.we = '1' then --store
              cache(to_integer(v.req1.a(CACHE_WIDTH-1 downto 0))) <= v.req1.d;
              tag(to_integer(v.req1.a(CACHE_WIDTH-1 downto 0))) <=
                '1' & v.req1.a(19 downto CACHE_WIDTH);
            elsif v.req1.we = '0' and tagd(20) = '1' and
              tagd(19 downto CACHE_WIDTH) = v.req1.a(19 downto CACHE_WIDTH) then
              -- load and cache hit
              vrep.d := cache(to_integer(v.req1.a(CACHE_WIDTH-1 downto 0)));
              vrep.complete := '1';
            else
              -- load and cache miss
              v.state := "01";
              vrep.busy := '1';
            end if;
          end if;

          if v.req2.go = '1' and v.req2.we = '1' and
            v.req2.a(19 downto ADDR_WIDTH) /= ones(19 downto ADDR_WIDTH) then
            v.data := v.req2.d;
            v.we := '1';
          end if;

        when "01" =>
          v.state := "10";
          vrep.busy := '1';
        when "10" =>
          v.state := "11";
          vrep.busy := '1';
        when "11" =>
          v.state := "00";
          vrep.d := r.ZD;
          cache(to_integer(v.req1.a(CACHE_WIDTH-1 downto 0))) <= r.ZD;
          tag(to_integer(v.req1.a(CACHE_WIDTH-1 downto 0))) <=
            '1' & v.req1.a(19 downto CACHE_WIDTH);
          vrep.complete := '1';
          v.req1 := default_memory_request;
        when others =>
          v.state := "00";
      end case;

      reply <= vrep;
      r <= v;
    end if;
  end process;

end MemoryCache_arch;
