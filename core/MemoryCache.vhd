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
    unsigned(31 downto 0);

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
    busy : std_logic;
    complete : unsigned(1 downto 0);
    da : unsigned(127 downto 0);
    db : unsigned(127 downto 0);
    wa : unsigned(3 downto 0);
    wb : unsigned(3 downto 0);
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

  signal cache_a0 : cache_t;
  signal cache_a1 : cache_t;
  signal cache_a2 : cache_t;
  signal cache_a3 : cache_t;
  signal cache_b0 : cache_t;
  signal cache_b1 : cache_t;
  signal cache_b2 : cache_t;
  signal cache_b3 : cache_t;
  signal taga : tag_t := init_tag('0');
  signal tagb : tag_t := init_tag('0');
  signal status : status_t := init_status('0');
  signal r : memory_cache_t :=
    (default_memory_request, "0000", (others => '-'), '0',
     (others => '-'), '0', "00", (others => '-'), (others => '-'),
     (others => '0'), (others => '0'));

begin
  ZA <= std_logic_vector(request.a) when r.state = "0000" else
        std_logic_vector(r.req.a);
  XWA <= not request.we when r.state = "0000" else
         not r.req.we;
  ZD <= std_logic_vector(r.data) when r.we = '1' else
        (others => 'Z');
  ADVA <= '1' when r.state = "0010" else
          '1' when r.state = "0011" else
          '1' when r.state = "1000" else
          '1' when r.state = "1001" else
          '1' when r.state = "1100" else
          '0';

  process(clk)
    variable v : memory_cache_t;
    variable baddr,next_baddr : unsigned(1 downto 0);
    variable index : unsigned(INDEXW-1 downto 0);
    variable tag : unsigned(TAGW-1 downto 0);
    variable vtaga, vtagb : unsigned(TAGW-1 downto 0);
    variable vstatus : unsigned(1 downto 0);
    variable da, db : unsigned(31 downto 0);
    variable wsel : unsigned(3 downto 0);
  begin
    if rising_edge(clk) then
      v := r;
      v.data := (others => '-');
      v.we := '0';
      v.ZD := unsigned(ZD);
      v.complete := "00";

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

      case baddr is
        when "00" => wsel := "0001";
        when "01" => wsel := "0010";
        when "10" => wsel := "0100";
        when others => wsel := "1000";
      end case;

      case r.state is
        when "0000" =>
          v.wa := "0000";
          v.wb := "0000";
          if v.req.go = '1' and
            v.req.a(19 downto ADDR_WIDTH) /= ones(19 downto ADDR_WIDTH) then
            if v.req.we = '1' and vstatus /= "00" and vtaga = tag then
              --store cache_a
              da := v.req.d;
              v.wa := wsel;
              if vstatus = "10" then
                vstatus := "11";
              end if;
            elsif v.req.we = '1' and vstatus(1) = '1' and vtagb = tag then
              -- store cache_b
              db := v.req.d;
              v.wb := wsel;
              vstatus := "10";
            elsif v.req.we = '1' and vstatus(0) = '0' then
              -- store cache_a
              vtaga := tag;
              da := v.req.d;
              v.wa := wsel;
              if vstatus(1) = '0' then
                vstatus := "01";
              else
                vstatus := "11";
              end if;
              v.req.we := '0';
              v.req.a := tag & index & next_baddr;
              v.state := "0001";
            elsif v.req.we = '1' then
              -- store cache_b
              vtagb := tag;
              db := v.req.d;
              v.wb := wsel;
              vstatus := "10";
              v.req.we := '0';
              v.req.a := tag & index & next_baddr;
              v.state := "0001";

            elsif v.req.we = '0' and vstatus /= "00" and
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
              v.busy := '1';
              v.state := "1000";
            end if;
          end if;

          if r.req.go = '1' and r.req.we = '1' and
            r.req.a(19 downto ADDR_WIDTH) /= ones(19 downto ADDR_WIDTH) then
            v.data := r.req.d;
            v.we := '1';
          end if;

        when "0001" => -- store miss
          v.state := "0010";
          v.data := r.req.d;
          v.we := '1';
        when "0010" =>
          v.state := "0011";
        when "0011" =>
          v.state := "0100";
        when "0100" =>
          v.state := "0101";
          v.wa := v.wa(2 downto 0) & v.wa(3);
          da := r.ZD;
          v.wb := v.wb(2 downto 0) & v.wb(3);
          db := r.ZD;
        when "0101" =>
          v.state := "0110";
          v.wa := v.wa(2 downto 0) & v.wa(3);
          da := r.ZD;
          v.wb := v.wb(2 downto 0) & v.wb(3);
          db := r.ZD;
        when "0110" =>
          v.state := "0000";
          v.wa := v.wa(2 downto 0) & v.wa(3);
          da := r.ZD;
          v.wb := v.wb(2 downto 0) & v.wb(3);
          db := r.ZD;

        when "1000" => -- load miss
          v.state := "1001";
          case vstatus is
            when "00" =>
              vtaga := tag;
              vstatus := "01";
              v.wa := wsel;
            when "01" | "11" =>
              vtagb := tag;
              vstatus := "10";
              v.wb := wsel;
            when "10" =>
              vtaga := tag;
              vstatus := "11";
              v.wa := wsel;
            when others =>
          end case;
        when "1001" =>
          v.state := "1100";
        when "1100" =>
          v.state := "1101";
          da := r.ZD;
          db := r.ZD;
          v.data := r.ZD;
          v.complete := "11";
        when "1101" =>
          v.state := "1110";
          da := r.ZD;
          v.wa := v.wa(2 downto 0) & v.wa(3);
          db := r.ZD;
          v.wb := v.wb(2 downto 0) & v.wb(3);
        when "1110" =>
          v.state := "1111";
          da := r.ZD;
          v.wa := v.wa(2 downto 0) & v.wa(3);
          db := r.ZD;
          v.wb := v.wb(2 downto 0) & v.wb(3);
        when "1111" =>
          v.state := "0000";
          da := r.ZD;
          v.wa := v.wa(2 downto 0) & v.wa(3);
          db := r.ZD;
          v.wb := v.wb(2 downto 0) & v.wb(3);
        when others =>
          v.state := "0000";
      end case;

      if r.state = "0000" or r.state(2) = '1' then
        if v.wa(0) = '1' then
          cache_a0(to_integer(index)) <= da;
        end if;
        if v.wa(1) = '1' then
          cache_a1(to_integer(index)) <= da;
        end if;
        if v.wa(2) = '1' then
          cache_a2(to_integer(index)) <= da;
        end if;
        if v.wa(3) = '1' then
          cache_a3(to_integer(index)) <= da;
        end if;

        if v.wb(0) = '1' then
          cache_b0(to_integer(index)) <= db;
        end if;
        if v.wb(1) = '1' then
          cache_b1(to_integer(index)) <= db;
        end if;
        if v.wb(2) = '1' then
          cache_b2(to_integer(index)) <= db;
        end if;
        if v.wb(3) = '1' then
          cache_b3(to_integer(index)) <= db;
        end if;
      end if;


      taga(to_integer(index)) <= vtaga;
      tagb(to_integer(index)) <= vtagb;
      status(to_integer(index)) <= vstatus;

      r <= v;
      r.da <= cache_a0(to_integer(index)) &
              cache_a1(to_integer(index)) &
              cache_a2(to_integer(index)) &
              cache_a3(to_integer(index));
      r.db <= cache_b0(to_integer(index)) &
              cache_b1(to_integer(index)) &
              cache_b2(to_integer(index)) &
              cache_b3(to_integer(index));

    end if;
  end process;

  reply.busy <= '0' when r.state = "0000" else
                '1';
  reply.complete <= '0' when r.complete = "00" else
                    '1';
  reply.d <= r.data when r.complete = "11" else
             r.da(127 downto 96) when r.complete = "01" and r.req.a(1 downto 0) = "00" else
             r.da(95 downto 64) when r.complete = "01" and r.req.a(1 downto 0) = "01" else
             r.da(63 downto 32) when r.complete = "01" and r.req.a(1 downto 0) = "10" else
             r.da(31 downto 0) when r.complete = "01" and r.req.a(1 downto 0) = "11" else
             r.db(127 downto 96) when r.complete = "10" and r.req.a(1 downto 0) = "00" else
             r.db(95 downto 64) when r.complete = "10" and r.req.a(1 downto 0) = "01" else
             r.db(63 downto 32) when r.complete = "10" and r.req.a(1 downto 0) = "10" else
             r.db(31 downto 0) when r.complete = "10" and r.req.a(1 downto 0) = "11" else
             (others => '-');

end MemoryCache_arch;
