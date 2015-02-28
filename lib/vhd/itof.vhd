library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity itof is
  port (
    x : in  std_logic_vector(31 downto 0);
    clk : in std_logic;
    r : out std_logic_vector(31 downto 0));
end itof;


architecture pipeline of itof is

signal a: std_logic_vector(31 downto 0);
begin
ftoi0:process(clk)

begin
	if rising_edge(clk) then
	if x(31)='1' then
		a<= ("00000000000000000000000000000000" nor x(31 downto 0)) + 1;
	else
		a<=x;
	end if;

	end if;
end process;
ftoi:process(clk)

	variable s: std_logic;
	variable exp: std_logic_vector(7 downto 0);
	variable frac: std_logic_vector(23 downto 0);


begin
	
	if rising_edge(clk) then

	if a(30)='1' then
	  frac:=("0" & a(29 downto 7)) + a(6);
	  if frac(23)='1' then
	    exp:="10011110";
	  else	
	    exp:="10011101";
	  end if;
	elsif a(29)='1' then
	  frac:=("0" & a(28 downto 6)) + a(5);
	  if frac(23)='1' then
	    exp:="10011101";
	  else	
	    exp:="10011100";
	  end if;

	elsif a(28)='1' then
	  frac:=("0" & a(27 downto 5)) + a(4);
	  if frac(23)='1' then
	    exp:="10011100";
	  else	
	    exp:="10011011";
	  end if;
	elsif a(27)='1' then
	  frac:=("0" & a(26 downto 4)) + a(3);
	  if frac(23)='1' then
	    exp:="10011011";
	  else	
	    exp:="10011010";
	  end if;

	elsif a(26)='1' then
	  frac:=("0" & a(25 downto 3)) + a(2);
	  if frac(23)='1' then
	    exp:="10011010";
	  else	
	    exp:="10011001";
	  end if;
	elsif a(25)='1' then
	  frac:=("0" & a(24 downto 2)) + a(1);
	  if frac(23)='1' then
	    exp:="10011001";
	  else	
	    exp:="10011000";
	  end if;
	elsif a(24)='1' then
	  frac:=("0" & a(23 downto 1)) + a(0);
	  if frac(23)='1' then
	    exp:="10011000";
	  else	
	    exp:="10010111";
	  end if;
	elsif a(23)='1' then
	  frac:=("0" & a(22 downto 0));	  
	  exp:="10010110";
	elsif a(22)='1' then
	  frac:=("0" & a(21 downto 0) & "0");	  
	  exp:="10010101";
	elsif a(21)='1' then
	  frac:=("0" & a(20 downto 0) & "00");	  
	  exp:="10010100";
	elsif a(20)='1' then
	  frac:=("0" & a(19 downto 0)& "000");	  
	  exp:="10010011";
	elsif a(19)='1' then
	  frac:=("0" & a(18 downto 0)& "0000");	  
	  exp:="10010010";
	elsif a(18)='1' then
	  frac:=("0" & a(17 downto 0)& "00000");	  
	  exp:="10010001";
	elsif a(17)='1' then
	  frac:=("0" & a(16 downto 0))& "000000";	  
	  exp:="10010000";
	elsif a(16)='1' then
	  frac:=("0" & a(15 downto 0)& "0000000");	  
	  exp:="10001111";
	elsif a(15)='1' then
	  frac:=("0" & a(14 downto 0)& "00000000");	  
	  exp:="10001110";
	elsif a(14)='1' then
	  frac:=("0" & a(13 downto 0)& "000000000");	  
	  exp:="10001101";
	elsif a(13)='1' then
	  frac:=("0" & a(12 downto 0)& "0000000000");	  
	  exp:="10001100";
	elsif a(12)='1' then
	  frac:=("0" & a(11 downto 0)& "00000000000");	  
	  exp:="10001011";
	elsif a(11)='1' then
	  frac:=("0" & a(10 downto 0)& "000000000000");	  
	  exp:="10001010";
	elsif a(10)='1' then
	  frac:=("0" & a(9 downto 0)& "0000000000000");	  
	  exp:="10001001";
	elsif a(9)='1' then
	  frac:=("0" & a(8 downto 0)& "00000000000000");	  
	  exp:="10001000";
	elsif a(8)='1' then
	  frac:=("0" & a(7 downto 0)& "000000000000000");	  
	  exp:="10000111";
	elsif a(7)='1' then
	  frac:=("0" & a(6 downto 0)& "0000000000000000");	  
	  exp:="10000110";
	elsif a(6)='1' then
	  frac:=("0" & a(5 downto 0)& "00000000000000000");	  
	  exp:="10000101";
	elsif a(5)='1' then
	  frac:=("0" & a(4 downto 0)& "000000000000000000");	  
	  exp:="10000100";
	elsif a(4)='1' then
	  frac:=("0" & a(3 downto 0)& "0000000000000000000");	  
	  exp:="10000011";
	elsif a(3)='1' then
	  frac:=("0" & a(2 downto 0)& "00000000000000000000");	  
	  exp:="10000010";
	elsif a(2)='1' then
	  frac:=("0" & a(1 downto 0)& "000000000000000000000");	  
	  exp:="10000001";
	elsif a(1)='1' then
	  frac:=("0" & a(0) & "0000000000000000000000");	  
	  exp:="10000000";
	elsif a(0)='1' then
	  frac:="000000000000000000000000";	  
	  exp:="01111111";
	else
	  frac:="000000000000000000000000";	  
	  exp:="00000000";

	end if;
		
	r<= x(31) & exp & frac(22 downto 0);

	end if;

end process;

end architecture;


