-- block is fixed at 4
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
    ADVA : out std_logic;
    request : in memory_request_t;
    reply : out memory_reply_t);
end MemoryCache;

architecture MemoryCache_arch of MemoryCache is
  constant INDEXW : integer := CACHE_INDEX_WIDTH;
  constant TAGW : integer := 20 - INDEXW - 2;

  type cache_t is array (2**INDEXW-1 downto 0) of
    unsigned(127 downto 0);

  type tag_t is array (2**INDEXW-1 downto 0) of
    unsigned(TAGW-1 downto 0);

  type status_t is array (2**INDEXW-1 downto 0) of
    unsigned(1 downto 0);
  --  "00" both unsued
  --  "01" only tag_a is used
  --  "10" both are used and tag_a is least recently used
  --  "11" both are used and tag_b is least recently used

  type memory_cache_t is record
    req : memory_request_t;
    state : unsigned(3 downto 0);
    data : unsigned(31 downto 0);
    we : std_logic; --write enable
    ZD : unsigned(31 downto 0);
    wa : unsigned(3 downto 0);
    wb : unsigned(3 downto 0);
  end record;

  constant initial_state : memory_cache_t := (
    req => default_memory_request,
    state => "0000",
    data => (others => '-'),
    we => '0',
    ZD => (others => '-'),
    wa => (others => '0'),
    wb => (others => '0'));

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
  signal r : memory_cache_t := initial_state;

begin
  ZA <= std_logic_vector(request.a) when r.state = "0000" else
        std_logic_vector(r.req.a);
  XWA <= not request.we when r.state = "0000" else
         '1';
  ZD <= std_logic_vector(r.data) when r.we = '1' else
        (others => 'Z');
  ADVA <= '0';

  process(clk)
    variable v : memory_cache_t;
    variable baddr,next_baddr : unsigned(1 downto 0);
    variable index : unsigned(INDEXW-1 downto 0);
    variable tag : unsigned(TAGW-1 downto 0);
    variable vtaga, vtagb : unsigned(TAGW-1 downto 0);
    variable vstatus : unsigned(1 downto 0);
    variable da, db, rda, rdb : unsigned(31 downto 0);
    variable oda, odb, ida, idb : unsigned(127 downto 0);
    variable vreply : memory_reply_t;
    variable sel : unsigned(3 downto 0);
  begin
    if rising_edge(clk) then
      v := r;
      v.data := (others => '-');
      v.we := '0';
      v.ZD := unsigned(ZD);
      vreply := ((others => '-'), '0', '0');

      if r.state = "0000" then
        v.req := request;
      end if;

      baddr := v.req.a(1 downto 0);
      next_baddr := baddr+1;
      index := v.req.a(INDEXW-1+2 downto 2);
      tag := v.req.a(19 downto 20-TAGW);
      vtaga := taga(to_integer(index));
      vtagb := tagb(to_integer(index));
      vstatus := status(to_integer(index));
      oda := cache_a(to_integer(index));
      odb := cache_b(to_integer(index));

      case baddr is
        when "00" =>
          sel := "0001";
          rda := oda(31 downto 0);
          rdb := odb(31 downto 0);
        when "01" =>
          sel := "0010";
          rda := oda(63 downto 32);
          rdb := odb(63 downto 32);
        when "10" =>
          sel := "0100";
          rda := oda(95 downto 64);
          rdb := odb(95 downto 64);
        when others =>
          sel := "1000";
          rda := oda(127 downto 96);
          rdb := odb(127 downto 96);
      end case;

      case r.state is
        when "0000" =>
          v.wa := "0000";
          v.wb := "0000";
          if v.req.go = '1' and
            v.req.a(19 downto ADDR_WIDTH) /= ones(19 downto ADDR_WIDTH) then
            if v.req.we = '1' and vstatus /= "00" and vtaga = tag then
              --store cache_a
              v.wa := sel;
              da := v.req.d;
              if vstatus = "10" then
                vstatus := "11";
              end if;
            elsif v.req.we = '1' and vstatus(1) = '1' and vtagb = tag then
              -- store cache_b
              v.wb := sel;
              db := v.req.d;
              vstatus := "10";
            elsif v.req.we = '1' and vstatus(0) = '0' then
              -- store cache_a
              vtaga := tag;
              v.wa := sel;
              da := v.req.d;
              vreply.busy := '1';
              if vstatus(1) = '0' then
                vstatus := "01";
              else
                vstatus := "11";
              end if;
              v.state := "0001";
              v.req.a := tag & index & next_baddr;
            elsif v.req.we = '1' then
              -- store cache_b
              vtagb := tag;
              v.wb := sel;
              db := v.req.d;
              vreply.busy := '1';
              vstatus := "10";
              v.state := "0001";
              v.req.a := tag & index & next_baddr;

            elsif v.req.we = '0' and vstatus /= "00" and
              vtaga = tag then
              -- load cache_a
              vreply.d := rda;
              vreply.complete := '1';
              if vstatus = "10" then
                vstatus := "11";
              end if;
            elsif v.req.we = '0' and vstatus(1) = '1' and
              vtagb = tag then
              -- load cache_b
              vreply.d := rdb;
              vreply.complete := '1';
            elsif v.req.we = '0' then
              -- load SRAM
              case vstatus is
                when "00" =>
                  vtaga := tag;
                  vstatus := "01";
                  v.wa := sel;
                when "01" | "11" =>
                  vtagb := tag;
                  vstatus := "10";
                  v.wb := sel;
                when "10" =>
                  vtaga := tag;
                  vstatus := "11";
                  v.wa := sel;
                when others =>
              end case;
              vreply.busy := '1';
              v.state := "1001";
              v.req.a := tag & index & next_baddr;
            end if;
          end if;

          if r.req.go = '1' and r.req.we = '1' and
            r.req.a(19 downto ADDR_WIDTH) /= ones(19 downto ADDR_WIDTH) then
            v.data := r.req.d;
            v.we := '1';
          end if;

        when "0001" => -- store miss
          v.data := r.req.d;
          v.we := '1';
          v.req.a := tag & index & next_baddr;
          vreply.busy := '1';
          v.state := "0010";
        when "0010" =>
          v.req.a := tag & index & next_baddr;
          vreply.busy := '1';
          v.state := "0011";
        when "0011" =>
          vreply.busy := '1';
          v.state := "0100";
        when "0100" =>
          v.wa := v.wa(2 downto 0) & v.wa(3);
          da := r.ZD;
          v.wb := v.wb(2 downto 0) & v.wb(3);
          db := r.ZD;
          vreply.busy := '1';
          v.state := "0101";
        when "0101" =>
          v.wa := v.wa(2 downto 0) & v.wa(3);
          da := r.ZD;
          v.wb := v.wb(2 downto 0) & v.wb(3);
          db := r.ZD;
          vreply.busy := '1';
          v.state := "0110";
        when "0110" =>
          v.wa := v.wa(2 downto 0) & v.wa(3);
          da := r.ZD;
          v.wb := v.wb(2 downto 0) & v.wb(3);
          db := r.ZD;
          v.state := "0000";

        when "1001" => -- load miss
          v.req.a := tag & index & next_baddr;
          vreply.busy := '1';
          v.state := "1010";
        when "1010" =>
          v.req.a := tag & index & next_baddr;
          vreply.busy := '1';
          v.state := "1100";
        when "1100" =>
          da := r.ZD;
          db := r.ZD;
          vreply.d := r.ZD;
          vreply.busy := '1';
          vreply.complete := '1';
          v.state := "1101";
        when "1101" =>
          da := r.ZD;
          db := r.ZD;
          v.wa := v.wa(2 downto 0) & v.wa(3);
          v.wb := v.wb(2 downto 0) & v.wb(3);
          v.state := "1110";
          vreply.busy := '1';
        when "1110" =>
          da := r.ZD;
          db := r.ZD;
          v.wa := v.wa(2 downto 0) & v.wa(3);
          v.wb := v.wb(2 downto 0) & v.wb(3);
          v.state := "1111";
          vreply.busy := '1';
        when "1111" =>
          da := r.ZD;
          db := r.ZD;
          v.wa := v.wa(2 downto 0) & v.wa(3);
          v.wb := v.wb(2 downto 0) & v.wb(3);
          v.state := "0000";
        when others =>
          v.state := "0000";
      end case;

      ida := oda;
      idb := odb;
      if r.state = "0000" or r.state(2) = '1' then
        if v.wa(0) = '1' then
          ida(31 downto 0) := da;
        end if;
        if v.wa(1) = '1' then
          ida(63 downto 32) := da;
        end if;
        if v.wa(2) = '1' then
          ida(95 downto 64) := da;
        end if;
        if v.wa(3) = '1' then
          ida(127 downto 96) := da;
        end if;

        if v.wb(0) = '1' then
          idb(31 downto 0) := db;
        end if;
        if v.wb(1) = '1' then
          idb(63 downto 32) := db;
        end if;
        if v.wb(2) = '1' then
          idb(95 downto 64) := db;
        end if;
        if v.wb(3) = '1' then
          idb(127 downto 96) := db;
        end if;
      end if;


      taga(to_integer(index)) <= vtaga;
      tagb(to_integer(index)) <= vtagb;
      status(to_integer(index)) <= vstatus;
      cache_a(to_integer(index)) <= ida;
      cache_b(to_integer(index)) <= idb;

      r <= v;
      reply <= vreply;

    end if;
  end process;

end MemoryCache_arch;
