library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity memory_io_u232c is
  generic (wtime: std_logic_vector(15 downto 0) := x"1ADB");
  Port ( clk  : in  STD_LOGIC;
         data : in  STD_LOGIC_VECTOR (7 downto 0);
         go   : in  STD_LOGIC;
         busy : out STD_LOGIC;
         tx   : out STD_LOGIC);
end memory_io_u232c;

architecture blackbox of memory_io_u232c is
  signal countdown: std_logic_vector(15 downto 0) := (others=>'0');
  signal sendbuf: std_logic_vector(8 downto 0) := (others=>'1');
  signal state: std_logic_vector(3 downto 0) := "1011";
begin
  statemachine: process(clk)
  begin
    if rising_edge(clk) then
      case state is
        when "1011"=>
          if go='1' then
            sendbuf<=data&"0";
            state<=state-1;
            countdown<=wtime;--+('0'&wtime(15 downto 1));
          end if;
        when "0010" =>
          if countdown=0 then
            sendbuf <= '1'&sendbuf(8 downto 1);
            countdown<='0'&wtime(15 downto 1);
            state<=state-1;
          else
            countdown<=countdown-1;
          end if;
                      
        when "0001" =>
          if countdown=0 then
            sendbuf<="1"&sendbuf(8 downto 1);
            countdown<=wtime;
            state<="1011";
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
  busy<= '0' when state="1011" else '1';
end blackbox;
