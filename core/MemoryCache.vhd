library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Util.all;

entity MemoryCache is
  generic (
    CACHE_WIDTH : integer := 8);
  port (
    clk : in std_logic;
    ZD : inout std_logic_vector(31 downto 0);
    ZA : out std_logic_vector(19 downto 0);
    XWA : out std_logic;
    mem_i : in mem_in_t;
    mem_o : out mem_out_t);
end MemoryCache;

architecture MemoryCache_arch of MemoryCache is

  type cache_t is array (2**CACHE_WIDTH-1 downto 0) of
    unsigned(31 downto 0);

  type tag_t is array (2**CACHE_WIDTH-1 downto 0) of
    unsigned(20 downto CACHE_WIDTH);

  type memory_cache_t is record
    buf1 : mem_in_t;
    buf2 : mem_in_t;
    stall : unsigned(1 downto 0);
    data : unsigned(31 downto 0);
    we : std_logic;
  end record;

  signal cache : cache_t;
  signal tag : tag_t;
  signal r : memory_cache_t;

begin
  ZA <= std_logic_vector(mem_i.m.a);
  XWA <= not mem_i.m.we;
  ZD <= std_logic_vector(r.data) when r.we = '1' else
        (others => 'Z');

  process(clk)
    variable vmem_i1, vmem_i2 : mem_in_t;
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
        vmem_i1 := mem_i;
        vmem_i2 := r.buf1;
      else
        vmem_i1 := r.buf1;
        vmem_i2 := r.buf2;
      end if;

      case r.stall is
        when "00" =>
          if vmem_i1.m.go = '1' and vmem_i1.m.a(19 downto 12) /= x"FF" then
            if vmem_i1.m.we = '1' then
              cache(to_integer(vmem_i1.m.a(CACHE_WIDTH-1 downto 0))) <= vmem_i1.m.d;
              tag(to_integer(vmem_i1.m.a(CACHE_WIDTH-1 downto 0))) <=
                '1' & vmem_i1.m.a(19 downto CACHE_WIDTH);
            end if;
            tagd := tag(to_integer(vmem_i1.m.a(CACHE_WIDTH-1 downto 0)));
            if tagd(20) = '1' and
              tagd(19 downto CACHE_WIDTH) = vmem_i1.m.a(19 downto CACHE_WIDTH) then
              mem_o.d <= cache(to_integer(vmem_i1.m.a(CACHE_WIDTH-1 downto 0)));
            else
              mem_o.d <= (others => '-');
              if vmem_i1.m.we = '0' then
                stall := '1';
              end if;
            end if;
          end if;

          if vmem_i2.m.go = '1' and vmem_i2.m.we = '1' and
            vmem_i2.m.a(19 downto 12) /= x"FF" then
            data := vmem_i2.m.d;
            we := '1';
          end if;
        when "01" =>
          mem_o.d <= (others => '-');
          stall := '1';
        when "10" =>
          mem_o.d <= unsigned(ZD);
        when others =>
          mem_o.d <= (others => '-');
      end case;

      if stall = '0' then
        r.buf1 <= vmem_i1;
        r.buf2 <= vmem_i2;
        r.stall <= "00";
      else
        r.stall <= r.stall+1;
      end if;

      mem_o.stall <= stall;
      r.data <= data;
      r.we <= we;

    end if;
  end process;

end MemoryCache_arch;
