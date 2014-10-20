-- a receiving component with buffering
-- if go rises, try to read from buffer. if there is
-- data in buffer, return the data when busy fall.
-- if no data in buffer wait for arrival of data to buffer
-- debug mode can use if you set debug true.


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity receive_buffer is
  generic(wtime : std_logic_vector(15 downto 0) := x"1ADB";
          debug : boolean := false);    
  port (
    clk : in std_logic;
    RS_RX : in std_logic;
    go : in std_logic;
    data : out std_logic_vector(31 downto 0);
    busy : out std_logic);
end receive_buffer;

architecture arch_receive_buffer of receive_buffer is
  component FIFO is
    generic (
      SIZE : integer := 256;
      WIDTH : integer := 8);
    port (
      clk : in std_logic;
      idata : in std_logic_vector(31 downto 0);
      odata : out std_logic_vector(31 downto 0);
      igo : in std_logic;
      ogo : in std_logic;
      empty : out std_logic;
      full : out std_logic);
  end component;

  component uart_receiver is
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime);
    port (
      clk  : in  std_logic;
      rx   : in  std_logic;
      complete : out std_logic;
      data : out std_logic_vector(7 downto 0));
  end component;

  component read_file is
    generic (wtime : std_logic_vector(15 downto 0) := wtime);
    port (
      clk : in std_logic;
      complete : out std_logic;
      data : out std_logic_vector(7 downto 0));
  end component;

  signal idata : std_logic_vector(31 downto 0);
  signal odata : std_logic_vector(31 downto 0);
  signal igo : std_logic := '0';
  signal ogo : std_logic := '0';
  signal empty : std_logic;

  signal io_complete : std_logic;
  signal bdata : std_logic_vector(7 downto 0);

  signal inbuf : std_logic_vector(31 downto 8);

  signal enq_state : std_logic_vector(2 downto 0) := "000";
  signal deq_state : std_logic_vector(1 downto 0) := "00";

begin

  receive_fifo : FIFO port map (
    clk => clk,
    idata => idata,
    odata => odata,
    igo => igo,
    ogo => ogo,
    empty => empty,
    full => open);

  fpga : if debug = false generate 
    receiver : uart_receiver port map (
      clk => clk,
      rx => RS_RX,
      complete => io_complete,
      data => bdata);
  end generate;

  sim : if debug = true generate
    read_data : read_file port map (
      clk => clk,
      complete => io_complete,
      data => bdata);
  end generate;

  enque : process(clk)
  begin
    if rising_edge(clk) then
      case enq_state is
        when "000" => -- get first byte
          igo <= '0';
          if io_complete = '1' then
            inbuf(31 downto 24) <= bdata;
            enq_state <= "001";
          end if;
        when "001" => --get second byte
          if io_complete = '1' then
            inbuf(23 downto 16) <= bdata;
            enq_state <= "010";
          end if;
        when "010" => --get third byte
          if io_complete = '1' then
            inbuf(15 downto 8) <= bdata;
            enq_state <= "011";
          end if;
        when "011" => --get forth byte and enque
          if io_complete = '1' then
            enq_state <= "000";
            idata <= inbuf(31 downto 8) & bdata;
            igo <= '1';
          end if;
        when others =>
          enq_state <= "000";
          igo <= '0';
      end case;
    end if;
  end process;

  deq : process(clk)
  begin
    if rising_edge(clk) then
      case deq_state is
        when "00" => --ready
          if go = '1' and empty = '0' then --if not empty
            ogo <= '1';
            deq_state <= "10";
          elsif go = '1' and empty = '1' then --if empty
            ogo <= '0';
            deq_state <= "01";
          else
            ogo <= '0';
          end if;
        when "01" => --wait for que
          if empty = '0' then
            ogo <= '1';
            deq_state <= "10";
          else
            ogo <= '0';
          end if;
        when "10" => --wait getting data
          ogo <= '0';
          deq_state <= "11";
        when "11" =>
          data <= odata;
          deq_state <= "00";
        when others =>
          ogo <= '0';
          deq_state <= "00";
      end case;
    end if;
  end process;

  busy <= '0' when deq_state = "00" else
          '1';
end arch_receive_buffer;

