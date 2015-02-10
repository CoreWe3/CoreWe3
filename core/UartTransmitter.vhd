library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UartTransmitter is
  generic (wtime: std_logic_vector(15 downto 0) := x"1ADB");
  port ( clk  : in  std_logic;
         data : in  std_logic_vector(7 downto 0);
         go   : in  std_logic;
         busy : out std_logic;
         tx   : out std_logic);
end UartTransmitter;

architecture UartTransmitter_arch of UartTransmitter is
  signal countdown: std_logic_vector(15 downto 0) := (others=>'0');
  signal sendbuf: std_logic_vector(8 downto 0) := (others=>'1');
  signal state: std_logic_vector(3 downto 0) := "1100";
begin
  statemachine: process(clk)
  begin
    if rising_edge(clk) then
      case state is
        when "1100"=>
          if go='1' then
            sendbuf<=data&"0";
            state<=state-1;
            countdown<=wtime;--+('0'&wtime(15 downto 1));
          end if;
        when "0010" =>
          if countdown=0 then
            sendbuf <= '1'&sendbuf(8 downto 1);
            --countdown<='0'&wtime(15 downto 1);
            countdown <= wtime;
            state<=state-1;
          else
            countdown<=countdown-1;
          end if;

        when "0001" =>
          if countdown=0 then
            sendbuf<="1"&sendbuf(8 downto 1);
            countdown<=wtime;
            state<="1100";
          else
            countdown<=countdown-1;
          end if;
        when others=>
          if countdown=0 then
            sendbuf<="1"&sendbuf(8 downto 1);
            countdown<=wtime;
            state<=state-1;
          else
            countdown<=countdown-1;
          end if;
      end case;
    end if;
  end process;
  tx<=sendbuf(0);
  busy<= '0' when state="1100" else '1';
end UartTransmitter_arch;
