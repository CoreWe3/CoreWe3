library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ftoi is
  port (
    x : in  std_logic_vector(31 downto 0);
    clk : in std_logic;
    r : out std_logic_vector(31 downto 0));
end ftoi;


architecture pipeline of ftoi is

	signal ansx : std_logic_vector(31 downto 0);
	signal sx: std_logic;
begin


ftoi:process(clk)
	variable ans : std_logic_vector(31 downto 0);
	variable s: std_logic;


begin
	if rising_edge(clk) then
	case x(30 downto 23) is
		when "10010110" =>
			ans :=  "000000001" & x(22 downto 0);
			s := '0';
		when "10010111" =>
			ans :=  "00000001" & x(22 downto 0) & "0";
			s := '0';
		when "10011000" =>
			ans :=  "0000001" & x(22 downto 0) & "00";
			s := '0';
		when "10011001" =>
			ans :=  "000001" & x(22 downto 0) & "000";
			s := '0';
		when "10011010" =>
			ans :=  "00001" & x(22 downto 0) & "0000";
			s := '0';
		when "10011011" =>
			ans :=  "0001" & x(22 downto 0) & "00000";
			s := '0';
		when "10011100" =>
			ans :=  "001" & x(22 downto 0) & "000000";
			s := '0';
		when "10011101" =>
			ans :=  "01" & x(22 downto 0) & "0000000";
			s := '0';
		when "10010100" =>
			ans := "0000000001" & x(22 downto 1);
			s :=x(0);
		when "10010101" =>
			ans := "00000000001" & x(22 downto 2);
			s :=x(1);
		when "10010011" =>
			ans := "000000000001" & x(22 downto 3);
			s :=x(2);
		when "10010010" =>
			ans := "0000000000001" & x(22 downto 4);
			s :=x(3);
		when "10010001" =>
			ans := "00000000000001" & x(22 downto 5);
			s :=x(4);
		when "10010000" =>
			ans := "000000000000001" & x(22 downto 6);
			s :=x(5);
		when "10001111" =>
			ans := "0000000000000001" & x(22 downto 7);
			s :=x(6);
		when "10001110" =>
			ans := "00000000000000001" & x(22 downto 8);
			s :=x(7);
		when "10001101" =>
			ans := "000000000000000001" & x(22 downto 9);
			s :=x(8);
		when "10001100" =>
			ans := "0000000000000000001" & x(22 downto 10);
			s :=x(9);
		when "10001011" =>
			ans := "00000000000000000001" & x(22 downto 11);
			s :=x(10);
		when "10001010" =>
			ans := "000000000000000000001" & x(22 downto 12);
			s :=x(11);
		when "10001001" =>
			ans := "0000000000000000000001" & x(22 downto 13);
			s :=x(12);
		when "10001000" =>
			ans := "00000000000000000000001" & x(22 downto 14);
			s :=x(13);
		when "10000111" =>
			ans := "000000000000000000000001" & x(22 downto 15);
			s :=x(14);
		when "10000110" =>
			ans := "0000000000000000000000001" & x(22 downto 16);
			s :=x(15);
		when "10000101" =>
			ans := "00000000000000000000000001" & x(22 downto 17);
			s :=x(16);
		when "10000100" =>
			ans := "000000000000000000000000001" & x(22 downto 18);
			s :=x(17);
		when "10000011" =>
			ans := "0000000000000000000000000001" & x(22 downto 19);
			s :=x(18);
		when "10000010" =>
			ans := "00000000000000000000000000001" & x(22 downto 20);
			s :=x(19);
		when "10000001" =>
			ans := "000000000000000000000000000001" & x(22 downto 21);
			s :=x(20);
		when "01111111" =>
			ans := "0000000000000000000000000000001" & x(22);
			s :=x(21);
		when "01111110" =>
			ans := "00000000000000000000000000000001";
			s :=x(22);
		when others =>
			ans := "00000000000000000000000000000000";
			s := '0';
	end case;
	ansx<=ans;	
	sx<=s;

	end if;
end process;

ftoi2:process(clk)
variable ans2 : std_logic_vector(31 downto 0);
begin
	
	if rising_edge(clk) then
	if sx='1' then
		ans2:= ansx+1;
	end if;

	if x(31) = '1' then
		r<= ("00000000000000000000000000000000" nor ans2) + 1; 
	else
		r<= ans2;
	end if;

	end if;

end process;

end architecture;


