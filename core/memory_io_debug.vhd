library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library unisim;
use unisim.VComponents.all;

entity memory_io_debug is
  
  port (
    mclk1 : in std_logic;
    RS_TX : out std_logic;
    RS_RX : in std_logic;
    ZA : out std_logic_vector(19 downto 0);
    XWA : out std_logic;
    ZD : inout std_logic_vector(31 downto 0);
    ZCLKMA : out std_logic_vector(1 downto 0);

    XE1 : out std_logic := '0';
    E2A :out std_logic := '1';
    XE3 : out std_logic := '0';
    XZBE : out std_logic_vector(3 downto 0) :=  "0000";
    XGA : out std_logic := '0';
    XZCKE :out std_logic := '0';
    ADVA : out std_logic := '0';
    XFT : out std_logic := '1';
    XLBO : out std_logic := '1';
    ZZA : out std_logic := '0');

end memory_io_debug;

architecture example of memory_io_debug is
  signal clk,iclk : std_logic;
  component memory_io
    port(
    clk        : in    std_logic;
    RS_RX      : in    std_logic;
    RS_TX      : out   std_logic;
    ZD         : inout std_logic_vector(31 downto 0);
    ZA         : out   std_logic_vector(19 downto 0);
    XWA        : out   std_logic;
    --バーストとか使うならピン追加可
    store_word : in    std_logic_vector(31 downto 0);
    load_word  : out   std_logic_vector(31 downto 0);
    addr       : in   std_logic_vector(19 downto 0);  --x"0ffff"でio
    load_store : in   std_logic;        --1ならstore
    go         : in    std_logic;
    busy       : out   std_logic);
  end component;
  signal store_word : std_logic_vector(31 downto 0) := (others => '0');
  signal load_word : std_logic_vector(31 downto 0) := (others => '0');
  signal addr : std_logic_vector(19 downto 0) := (others => '0');
  signal load_store : std_logic;
  signal go : std_logic := '0';
  signal busy : std_logic;
  signal state : std_logic_vector(3 downto 0) := "0000";
  signal count : std_logic_vector(7 downto 0) := x"30";
  signal allbit : std_logic_vector(31 downto 0) := (others => '0');
  signal temp  : std_logic_vector(15 downto 0) := (others => '0');
begin  -- example
  XE1		<='0';
  E2A		<='1';
  XE3		<='0';
  XZBE	<="0000";
  XGA		<='0';
  XZCKE	<='0';
  ADVA	<='0';
  XFT		<='1';
  XLBO	<='1';
  ZZA		<='0';
  ZCLKMA(0)<=clk;
  ZCLKMA(1)<=clk;
  
  ib: IBUFG port map (
    i=>MCLK1,
    o=>iclk);
  bg: BUFG port map (
    i=>iclk,
    o=>clk);
  debug_m_i: memory_io
    port map (clk,RS_RX,RS_TX,ZD,ZA,XWA,store_word,load_word,addr,load_store,go,busy);
  process(clk)
  begin
    if rising_edge(clk) then
      case state is
        when "0000" =>
          addr <= x"0ffff";
          load_store <= '0';
          go <= '1';
          state <= "0001";
        when "0001" =>
          if go = '0' and busy = '0' then
            store_word <= load_word;
            load_store <= '1';
            go <= '1';
            state <= "0010";
          else
            go <= '0';
          end if;
        when "0010" =>
          if go ='0' and busy = '0' then
            state <= "0000";
          else
              go <= '0';
          end if;
        when "0100" =>
          count <= x"30";
          if go <= '0' and busy = '0' then
            load_store <= '1';
            temp <= temp + 1;
            if temp(1 downto 0) = "00"  then
              addr <= x"00000";
              store_word <= x"30303030";
            else
              if temp(1 downto 0) = "01" then
                addr <= x"00001";
                store_word <= x"31313131";
              else
                if temp( 1 downto 0) = "10" then
                  addr <= x"00002";
                  store_word <= x"32323232";
                else
                  addr <= x"00003";
                  store_word <= x"33333333";
                end if;
              end if;
            end if;
            go <= '1';
          else
            go <= '0';
            state <= "0101";
          end if;
        when "0101" =>
          if go = '0' and busy = '0' then
            load_store <= '0';
            go <= '1';
          else
            go <= '0';
            state <= "0110";
          end if;
        when "0110" =>
          if go = '0' and busy = '0' then
            --if load_word = x"12345678" then
            count <= load_word(7 downto 0);
            state <= "0111";
            --end if;
          end if;

          
        when "0111" =>
          if go <= '0' and busy = '0' and addr = x"0fffe" then
            load_store <= '0';
            go <= '0';
            count <= x"30";
            addr <= (others => '0');
            state <="1000";
          else
            if go = '0' and busy = '0' then
              go <= '1';
              addr <= addr + 1;
              load_store <= '1';
            else
              go <= '0';
              store_word <= x"000" & addr;
            end if;
          end if;
        when "1000" =>
          if busy = '0' and addr = x"0fffe" then
            go <= '0';
            load_store <= '1';
            state <= "1010";
          else
            if go = '0' and busy = '0' then
              go <= '1';
              if load_word(19 downto 0) + 1 = addr then
                addr <= addr + 1;
              else
                if addr = x"00000" or addr = x"00001" then
                  count <= count + 1; --
                  addr <= addr + 1;
                else   
                  count <= count + 1;
                  addr <= addr + 1;
                end if;
              end if;
            else
              go <= '0';
            end if;
          end if;
        when "1010" =>
          if go = '0' and busy = '0' then
            go <= '1';
            addr <= x"0ffff";
            load_store <= '1';
            --store_word <= x"303030" & count;
            store_word <= load_word;
            state <= "1100";
          else
            go <= '0';
          end if;
        when "1100" =>
          if go = '0' and busy = '0' then
            state <= "0000";
          else
            go <= '0';
          end if;
        when others =>
          if addr = x"0fffe" then
            state <= "0000";
          end if;
      end case;
    end if;
  end process;
end example;
