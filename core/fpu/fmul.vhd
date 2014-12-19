library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity fmul is
  port (
    x : in  std_logic_vector(31 downto 0);
    y : in  std_logic_vector(31 downto 0);
    clk : in std_logic;
    r : out std_logic_vector(31 downto 0));
end Fmul;


architecture pipeline of fmul is


begin
fmul1:process(clk)

	variable lh :std_logic_vector(23 downto 0);
	variable hl :std_logic_vector(23 downto 0);
	variable hh :std_logic_vector(25 downto 0);
	variable sign : std_logic;
	variable exp : std_logic_vector(8 downto 0);
	variable exp2 : std_logic_vector(8 downto 0);
	variable frac : std_logic_vector(22 downto 0);
	variable fractmp : std_logic_vector(25 downto 0);

begin
	if rising_edge(clk) then
	hh:=("1" & x(22 downto 11)) * ("1" & y(22 downto 11));
	hl:=("1" & x(22 downto 11)) * y(10 downto 0);
	lh:=x(10 downto 0) * ("1" & y(22 downto 11));
	exp:=('0' & x(30 downto 23)) +('0' & y(30 downto 23)) + 129;
	sign:=x(31) XOR y(31);
	fractmp:=hh+hl(23 downto 11)+lh(23 downto 11)+2;
	exp2:=exp+1;
	if exp(8)='0' then
		r<=sign & "0000000000000000000000000000000";
	else
		if fractmp(25)='0' then
			r<=sign & exp(7 downto 0)& fractmp(23 downto 1);
		else
			r<=sign & exp2(7 downto 0)& fractmp(24 downto 2);
		end if;
	end if;	
	end if;
end process;

end architecture;
