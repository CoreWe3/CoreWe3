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

  type cache_t is array (2**CACHE_INDEX-1 downto 0) of
    unsigned(31 downto 0);

  type tag_t is array (2**CACHE_INDEX-1 downto 0) of
    unsigned(19-CACHE_INDEX downto 0);

  type status_t is array (2**CACHE_INDEX-1 downto 0) of
    unsigned(1 downto 0);
  --  "00" both unsued
  --  "01" only tag_a is used
  --  "10" both are used and tag_a is least recently used
  --  "11" both are used and tag_b is least recently used

  type memory_cache_t is record
    req : memory_request_t;
    state : unsigned(1 downto 0);
    data : unsigned(31 downto 0);
    we : std_logic; --write enable
    ZD : unsigned(31 downto 0);
    busy : std_logic;
    complete : unsigned(1 downto 0);
    da : unsigned(31 downto 0);
    db : unsigned(31 downto 0);
  end record;

  impure function init_tag(dummy : in std_logic) return tag_t is
    variable tag : tag_t;
  begin
    for i in tag_t'range loop
      tag(i) := (others => '0');
    end loop;
    return tag;
  end function;

  impure function init_status(dummy : in std_logic) return status_t is
    variable status : status_t;
  begin
    for i in status_t'range loop
      status(i) := (others => '0');
    end loop;
    return status;
  end function;

  signal cache_a : cache_t;
  signal cache_b : cache_t;
  signal taga : tag_t := init_tag('0');
  signal tagb : tag_t := init_tag('0');
  signal status : status_t := init_status('0');
  signal r : memory_cache_t :=
    (default_memory_request, "00", (others => '-'), '0',
     (others => '-'), '0', "00", (others => '-'), (others => '-'));

begin
  ZA <= std_logic_vector(request.a);
  XWA <= not request.we;
  ZD <= std_logic_vector(r.data) when r.we = '1' else
        (others => 'Z');

  process(clk)
    variable v : memory_cache_t;
    variable index : unsigned(CACHE_INDEX-1 downto 0);
    variable tag : unsigned(19 downto CACHE_INDEX);
    variable vtaga, vtagb : unsigned(19-CACHE_INDEX downto 0);
    variable vstatus : unsigned(1 downto 0);
    variable da, db : unsigned(31 downto 0);
    variable wa, wb : std_logic;
  begin
    if rising_edge(clk) then
      v := r;
      v.data := (others => '-');
      v.we := '0';
      wa := '0';
      wb := '0';
      v.ZD := unsigned(ZD);
      v.complete := "00";

      if r.state = "00" then
        v.req := request;
      end if;

      index := v.req.a(CACHE_INDEX-1 downto 0);
      tag := v.req.a(19 downto CACHE_INDEX);
      vtaga := taga(to_integer(index));
      vtagb := tagb(to_integer(index));
      vstatus := status(to_integer(index));

      case r.state is
        when "00" =>
          if v.req.go = '1' and
            v.req.a(19 downto ADDR_WIDTH) /= ones(19 downto ADDR_WIDTH) then
            if v.req.we = '1' and vstatus /= "00" and vtaga = tag then
              --store cache_a
              da := v.req.d;
              wa := '1';
              if vstatus = "10" then
                vstatus := "11";
              end if;
            elsif v.req.we = '1' and vstatus(1) = '1' and vtagb = tag then
              -- store cache_b
              db := v.req.d;
              wb := '1';
              vstatus := "10";
            elsif v.req.we = '1' and vstatus(0) = '0' then
              -- store cache_a
              vtaga := tag;
              da := v.req.d;
              wa := '1';
              if vstatus(1) = '0' then
                vstatus := "01";
              else
                vstatus := "11";
              end if;
            elsif v.req.we = '1' then -- store cache_b
              vtagb := tag;
              db := v.req.d;
              wb := '1';
              vstatus := "10";
            end if;
            if v.req.we = '0' and vstatus /= "00" and
              vtaga = tag then
              -- load cache_a
              v.complete := "01";
              if vstatus = "10" then
                vstatus := "11";
              end if;
            elsif v.req.we = '0' and vstatus(1) = '1' and
              vtagb = tag then
              -- load cache_b
              v.complete := "10";
            elsif v.req.we = '0' then
              -- load SRAM
              v.state := "01";
              v.busy := '1';
            end if;
          end if;

          if r.req.go = '1' and r.req.we = '1' and
            r.req.a(19 downto ADDR_WIDTH) /= ones(19 downto ADDR_WIDTH) then
            v.data := r.req.d;
            v.we := '1';
          end if;

        when "01" =>
          v.state := "10";
        when "10" =>
          v.state := "11";
        when "11" =>
          v.state := "00";
          v.complete := "11";
          v.data := r.ZD;
          case vstatus is
            when "00" =>
              da := r.ZD;
              wa := '1';
              vtaga := tag;
              vstatus := "01";
            when "01" | "11" =>
              db := r.ZD;
              wb := '1';
              vtagb := tag;
              vstatus := "10";
            when "10" =>
              da := r.ZD;
              wa := '1';
              vtaga := tag;
              vstatus := "11";
            when others =>
          end case;
          v.req := default_memory_request;
          v.busy := '0';
        when others =>
          v.state := "00";
      end case;

      if wa = '1' then
        cache_a(to_integer(index)) <= da;
      end if;

      if wb = '1' then
        cache_b(to_integer(index)) <= db;
      end if;

      taga(to_integer(index)) <= vtaga;
      tagb(to_integer(index)) <= vtagb;
      status(to_integer(index)) <= vstatus;

      r <= v;
      r.da <= cache_a(to_integer(index));
      r.db <= cache_b(to_integer(index));

    end if;
  end process;

  reply.busy <= r.busy;
  reply.complete <= '0' when r.complete = "00" else
                    '1';
  reply.d <= r.data when r.complete = "11" else
             r.da when r.complete = "01" else
             r.db when r.complete = "10" else
             (others => '-');

end MemoryCache_arch;
