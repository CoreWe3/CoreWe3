library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity transmit_buffer is
  generic(wtime : std_logic_vector(15 downto 0) := x"1ADB");
  port (
    clk : in std_logic;
    RS_TX : out std_logic;
    go : in std_logic;
    data : in std_logic_vector(31 downto 0);
    busy : out std_logic);
end transmit_buffer;

architecture arch_transmit_buffer of transmit_buffer is
  component FIFO is
    generic (
      SIZE : integer := 256;
      WIDTH : integer := 8);
    port (
      clk : in std_logic;
      idata : in std_logic_vector(7 downto 0);
      odata : out std_logic_vector(7 downto 0);
      igo : in std_logic;
      ogo : in std_logic;
      empty : out std_logic;
      full : out std_logic);
  end component;

  component uart_transmitter is
    generic (wtime: std_logic_vector(15 downto 0) := wtime);
    Port ( clk  : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR (7 downto 0);
           go   : in  STD_LOGIC;
           busy : out STD_LOGIC;
           tx   : out STD_LOGIC);
  end component;

  signal idata : std_logic_vector(7 downto 0);
  signal odata : std_logic_vector(7 downto 0);
  signal igo : std_logic := '0';
  signal ogo : std_logic := '0';
  signal empty : std_logic;
  signal full : std_logic;
  signal io_go : std_logic := '0';
  signal inbuf : std_logic_vector(7 downto 0);
  signal outbuf : std_logic_vector(7 downto 0);
  signal bdata : std_logic_vector(7 downto 0);
  signal io_busy : std_logic;
  signal enq_state : std_logic_vector(1 downto 0) := "00";
  signal deq_state : std_logic_vector(2 downto 0) := "000";
begin
  
  transmit_fifo : fifo port map (
    clk => clk,
    idata => idata,
    odata => odata,
    igo => igo,
    ogo => ogo,
    empty => empty,
    full => full);

  transmitter : uart_transmitter port map (
    clk => clk,
    data => bdata,
    go => io_go,
    busy => io_busy,
    tx => RS_TX);

  enque : process(clk)
  begin
    if rising_edge(clk) then
      case enq_state is
        when "00" => --ready
          if go = '1' then
            if full = '0' then --not full
              idata <= data(7 downto 0);
              igo <= '1';
              enq_state <= "10";
            else --full
              inbuf <= data(7 downto 0);
              igo <= '0';
              enq_state <= "01";
            end if;
          else
            igo <= '0';
          end if;
        when "01" => --wait for queue
          if full = '0' then
            idata <= inbuf;
            igo <= '1';
            enq_state <= "10";
          else
            igo <= '0';
          end if;
        when "10" => --complete
          igo <= '0';
          enq_state <= "00";
        when others =>
          igo <= '0';
          enq_state <= "00";
      end case;
    end if;
  end process;

  busy <= '0' when enq_state = "00" else
          '1';

  deque : process(clk)
  begin
    if rising_edge(clk) then
      --case deq_state is
      --  when "000" => --ready
      --    io_go <= '0';
      --    if empty = '0' then --if not empty
      --      ogo <= '1';
      --      deq_state <= "001";
      --    else
      --      ogo <= '0';
      --    end if;
      --  when "001" => --wait getting data from queue
      --    ogo <= '0';
      --    io_go <= '0';
      --    deq_state <= "010";
      --  when "010" => --vain state
      --    outbuf <= odata;
      --    deq_state <= "011";
      --  when "011" => --transmit first byte
      --    if io_busy = '0' and io_go = '0' then
      --      bdata <= outbuf(31 downto 24);
      --      io_go <= '1';
      --      deq_state <= "100";
      --    else
      --      io_go <= '0';
      --    end if;
      --  when "100" => --transmit second byte
      --    if io_busy = '0' and io_go = '0' then
      --      bdata <= outbuf(23 downto 16);
      --      io_go <= '1';
      --      deq_state <= "101";
      --    else
      --      io_go <= '0';
      --    end if;
      --  when "101" => --transmit third byte
      --    if io_busy = '0' and io_go = '0' then
      --      bdata <= outbuf(15 downto 8);
      --      io_go <= '1';
      --      deq_state <= "110";
      --    else
      --      io_go <= '0';
      --    end if;
      --  when "110" => --transmit forth byte
      --    if io_busy = '0' and io_go = '0' then
      --      bdata <= outbuf(7 downto 0);
      --      io_go <= '1';
      --      deq_state <= "000";
      --    else
      --      io_go <= '0';
      --    end if;
      --  when others =>
      --    deq_state <= "000";
      --    io_go <= '0';
      --end case;

      case deq_state is
        when "000" => --ready
          io_go <= '0';
          if empty = '0' then
            ogo <= '1';
            deq_state <= "001";
          end if;
        when "001" => --read wait
          ogo <= '0';
          deq_state <= "010";
        when "010" =>
          outbuf <= odata;
          if io_go = '0' and io_busy = '0' then
            io_go <= '1';
            bdata <= odata;
            deq_state <= "000";
          else
            deq_state <= "011";
          end if;
        when "011" =>
          if io_go = '0' and io_busy = '0' then
            io_go <= '1';
            bdata <= outbuf;
            deq_state <= "000";
          end if;
        when others =>
          io_go <= '0';
          ogo <= '0';
          deq_state <= "000";
      end case;
    end if;
  end process;
end arch_transmit_buffer;
                   
