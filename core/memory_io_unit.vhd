--receive用bufferは0xf800から0xf9fffまで(仮)
--send用bufferは0xfa000から0xfafffまで(仮)

library ieee;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
entity memory_io_unit is
  
  port (
    clk         : in    std_logic;
    rs_rx       : in    std_logic;
    rs_tx       : out   std_logic;
    ZD          : inout std_logic_vector(31 downto 0);
    ZA          : out   std_logic_vector(19 downto 0);
    XWA         : out   std_logic;
    --cpu_raddr   : in    std_logic_vector(19 downto 0);
    raddr       : out   std_logic_vector(19 downto 0); --まだ空
    cpu_uaddr   : in    std_logic_vector(19 downto 0);  
    uaddr       : out   std_logic_vector(19 downto 0); 
    rmemory_busy : out   std_logic;
    umemory_busy : out   std_logic;
    memory_busy  : in    std_logic);
    --umemory_size : in    std_logic_vector(19 downto 0));

end memory_io_unit;

architecture example of memory_io_unit is
  component memory_io_u232c
    generic (wtime: std_logic_vector(15 downto 0) := x"1ADB");
    Port ( clk  : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR (7 downto 0);
           go   : in  STD_LOGIC;
           busy : out STD_LOGIC;
           tx   : out STD_LOGIC);
  end component;

  component memory_io_r232c
    generic (
      wtime : std_logic_vector(15 downto 0) := x"1ADB");
    port (
      clk  : in  std_logic;
      rx   : in  std_logic;
      owari: out std_logic;
      data : out std_logic_vector(7 downto 0));
  end component;
  signal rstate : std_logic_vector(2 downto 0) := (others => '0');
  signal ustate : std_logic_vector(3 downto 0) := (others => '0');
  signal rdata : std_logic_vector(7 downto 0);
  signal rminibuffer : std_logic_vector(31 downto 0) := (others => '0');
  signal udata : std_logic_vector(7 downto 0);
  signal uminibuffer : std_logic_vector(31 downto 0) := (others => '1');
  signal uart_go: std_logic := '0';
  signal uart_busy: std_logic := '0';
  signal owari : std_logic;
  signal cansend : std_logic := '0';
  signal temp : std_logic := '1';       -- rs_rx
  signal rsize : std_logic_vector(19 downto 0) := x"1ffff";
  signal usize : std_logic_vector(19 downto 0) := x"1ffff";
  signal rhead : std_logic_vector(19 downto 0) := x"f8000";
  signal uhead : std_logic_vector(19 downto 0) := x"fa000";
  
begin  -- example
  nr232c : memory_io_r232c generic map (wtime => x"1adb")
    port map (clk,temp,owari,rdata);
  nu232c: memory_io_u232c generic map (wtime=>x"1b16")
    port map (
      clk=>clk,
      data=>udata,
      go=>uart_go,
      busy=>uart_busy,
      tx=>rs_tx);
  mio: process (clk)
  begin  -- process mio
    if rising_edge(clk) then
      temp <= rs_rx;
      case rstate is
        when "000" =>
          rmemory_busy <= '0';
          raddr <= rhead;
          rstate <= "001";
        when "001" =>
          if owari = '1' then
            rminibuffer(31 downto 24) <= rdata;
            rstate <= "010";
          end if;;
        when "010" =>
          if owari = '1' then
            rminibuffer(23 downto 16) <= rdata;
            rstate <= "011";
          end if;
        when "011" =>
          if owari = '1' then
            rminibuffer(15 downto 8) <= rdata;
            rstate <= "100";
          end if;
        when "100" =>
          if owari = '1' then
            rminibuffer(7 downto 0) <= rdata;
            rstate <= "101";
          end if;
        when "101" =>
          if umemory_busy = '1' or memory_busy = '1' then
            rstate <= "101";
          end if;
          ZD <= rminibuffer;
          XWA <= '0';
          ZA <= raddr;
          rstate <= "110";
          rmemory_busy <= '1';
        when "110" =>
          if raddr = rhead + rsize then
            raddr <= rhead;
          else
            raddr <= raddr + 1;
          end if;
          rmemory_busy <= '0';
          rstate <= "001";
        when others =>
          rstate <= "000";
      end case;
      case ustate is
        when "0000" =>
          uaddr <= uhead;
          umemory_busy <= '0';
          ustate <= "0001";
        when "0001" =>
          if uaddr /= cpu_uaddr and then
            if rmemory_busy = '1' or memory_busy = '1' then
              ustate <= "0001";
            end if;
            ZD <= (others => 'Z');
            XWA <= '1';
            ZA <= uaddr;
            umemory_busy <= '1';
            ustate <= "0010";
          end if;
        when "0010" =>
          uminibuffer <= ZD;
          umemory_busy <= '0';
          if uaddr = uhead + usize then
            uaddr <= uhead;
          else
            uaddr <= uaddr + 1;
          end if;
          ustate <= "0011";
        when "0011" =>
          if cansend = '1' and uart_go = '0' and uart_busy = '0'then
            uart_go <= '1';
            cansend <= '0';
          else
            if cansend = '0' and uart_go = '0' and uart_busy = '0' then
              cansend <= '1';
              udata <= uminibuffer(31 downto 24);
              state <= "0100";
            end if;
            uart_go <= '0';
          end if;
        when "0100" =>
          if cansend = '1' and uart_go = '0' and uart_busy = '0'then
            uart_go <= '1';
            cansend <= '0';
          else
            if cansend = '0' and uart_go = '0' and uart_busy = '0' then
              cansend <= '1';
              udata <= uminibuffer(23 downto 16);
              state <= "0101";
            end if;
            uart_go <= '0';
          end if;
        when "0101" =>
          if cansend = '1' and uart_go = '0' and uart_busy = '0'then
            uart_go <= '1';
            cansend <= '0';
          else
            if cansend = '0' and uart_go = '0' and uart_busy = '0' then
              cansend <= '1';
              udata <= uminibuffer(15 downto 8);
              state <= "0110";
            end if;
            uart_go <= '0';
          end if;
        when "0110" =>
          if cansend = '1' and uart_go = '0' and uart_busy = '0'then
            uart_go <= '1';
            cansend <= '0';
          else
            if cansend = '0' and uart_go = '0' and uart_busy = '0' then
              cansend <= '1';
              udata <= uminibuffer(7 downto 0);
              state <= "0111";
            end if;
            uart_go <= '0';
          end if;
        when "0111" =>
          ustate <= "0001";
        when others =>
          ustate <= "0000";
      end case;
    end if;
  end process mio;
end example;
