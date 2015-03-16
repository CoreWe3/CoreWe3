library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity floor is
  port (
    x : in  std_logic_vector(31 downto 0);
    clk : in std_logic;
    r : out std_logic_vector(31 downto 0));
end floor;


architecture floor_arch of floor is

signal tmp: std_logic_vector(31 downto 0);
signal flag: std_logic_vector(22 downto 0);
signal flag2: std_logic;

begin
floor:process(clk)


variable exp: std_logic_vector(7 downto 0);

begin
	
	if rising_edge(clk) then

	exp<=x(30 downto 23);

--stage1
	if exp="10010101" then

		if x(0)='0' then
		   flag<="00000000000000000000000";
		else
		   flag<="00000000000000000000010";
		    if x(23) downto (1)="11111111111111111111111" then
			flag2<='1';

		    else
			flag2<='0';
		    end if;

		end if;
		tmp<= x(31) downto (1) & "0";

	else if exp="10010100" then


		if x(1 downto 0)="00" then
		   flag<="00000000000000000000000";
		else
		   flag<="00000000000000000000100";
		    if x(23) downto (2)="1111111111111111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31) downto (2) & "00";

	else if exp="10010011" then


		if x(2 downto 0)="000" then
		   flag<="00000000000000000000000";
		else
		   flag<="00000000000000000001000";
		    if x(23) downto (3)="111111111111111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31) downto (3) & "000";

	else if exp="10010010" then


		if x(3 downto 0)="0000" then
		   flag<="00000000000000000000000";
		else
		   flag<="00000000000000000010000";
		    if x(23) downto (4)="11111111111111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31) downto (4) & "0000";

	else if exp="10010001" then

		if x(4 downto 0)="00000" then
		   flag<="00000000000000000000000";
		else
		   flag<="00000000000000000100000";
		    if x(23) downto (5)="1111111111111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31) downto (5) & "00000";

	else if exp="10010000" then

		if x(5 downto 0)="000000" then
		   flag<="00000000000000000000000";
		else
		   flag<="00000000000000001000000";
		    if x(23) downto (6)="111111111111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31) downto (6) & "000000";

	else if exp="10001111" then

		if x(6 downto 0)="0000000" then
		   flag<="00000000000000000000000";
		else
		   flag<="00000000000000010000000";
		    if x(23) downto (7)="11111111111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31) downto (7) & "0000000";


	else if exp="10001110" then

		if x(7 downto 0)="00000000" then
		   flag<="00000000000000000000000";
		else
		   flag<="00000000000000100000000";
		    if x(23) downto (8)="1111111111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31) downto (8) & "00000000";


	else if exp="10001101" then

		if x(8 downto 0)="000000000" then
		   flag<="00000000000000000000000";
		else
		   flag<="00000000000001000000000";
		    if x(23) downto (9)="111111111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31) downto (9) & "000000000";

	else if exp="10001100" then

		if x(9 downto 0)="0000000000" then
		   flag<="00000000000000000000000";
		else
		   flag<="00000000000010000000000";
		    if x(23) downto (11)="1111111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31) downto (10) & "0000000000";



	else if exp="10001011" then

		if x(10 downto 0)="00000000000" then
		   flag<="00000000000000000000000";
		else
		   flag<="00000000000100000000000";
		    if x(23) downto (12)="111111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31) downto (11) & "00000000000";

	else if exp="10001010" then

		if x(11 downto 0)="000000000000" then
		   flag<="00000000000000000000000";
		else
		   flag<="00000000001000000000000";
		    if x(23) downto (13)="11111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31) downto (12) & "000000000000";

	else if exp="10001001" then

		if x(12 downto 0)="000000000000" then
		   flag<="00000000000000000000000";
		else
		   flag<="00000000010000000000000";
		    if x(23) downto (14)="1111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31) downto (13) & "0000000000000";

	else if exp="10001000" then

		if x(13 downto 0)="0000000000000" then
		   flag<="00000000000000000000000";
		else
		   flag<="00000000100000000000000";
		    if x(23) downto (15)="111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31) downto (14) & "00000000000000";

	else if exp="10000111" then

		if x(14 downto 0)="00000000000000" then
		   flag<="00000000000000000000000";
		else
		   flag<="00000001000000000000000";
		    if x(23) downto (16)="11111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31) downto (15) & "000000000000000";

	else if exp="10000110" then

		if x(15 downto 0)="000000000000000" then
		   flag<="00000000000000000000000";
		else
		   flag<="00000010000000000000000";
		    if x(23) downto (17)="1111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31) downto (16) & "0000000000000000";

	else if exp="10000101" then

		if x(16 downto 0)="0000000000000000" then
		   flag<="00000000000000000000000";
		else
		   flag<="00000100000000000000000";
		    if x(23) downto (18)="111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31) downto (17) & "00000000000000000";

	else if exp="10000100" then

		if x(17 downto 0)="00000000000000000" then
		   flag<="00000000000000000000000";
		else
		   flag<="00001000000000000000000";
		    if x(23) downto (19)="11111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31) downto (18) & "000000000000000000";


	else if exp="10000011" then

		if x(18 downto 0)="000000000000000000" then
		   flag<="00000000000000000000000";
		else
		   flag<="00010000000000000000000";
		    if x(23) downto (20)="1111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31) downto (19) & "0000000000000000000";


	else if exp="10000010" then

		if x(19 downto 0)="0000000000000000000" then
		   flag<="00000000000000000000000";
		else
		   flag<="00100000000000000000000";
		    if x(23) downto (21)="111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31) downto (20) & "00000000000000000000";

	else if exp="10000001" then

		if x(20 downto 0)="00000000000000000000" then
		   flag<="00000000000000000000000";
		else
		   flag<="01000000000000000000000";
		    if x(23) downto (22)="11" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31) downto (21) & "00000000000000000000";

	else if exp="10000000" then

		if x(21 downto 0)="000000000000000000000" then
		   flag<="00000000000000000000000";
		else
		   flag<="10000000000000000000000";
		    if x(22)='1' then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31) downto (22) & "0000000000000000000000";
	else if exp="01111111" then

		if x(22 downto 0)="000000000000000000000" then
		   flag2<='0';
		else
		   flag2<='1';
		end if;
		   flag<="00000000000000000000000";
		tmp<= x(31) downto (23) & "00000000000000000000000";

	else if exp(8)='0' then
		if x(31)='1' then
		   if x(30 downto 0)="0000000000000000000000000000000" then
			flag2<='0';
		   else
		 	flag2<='1';
		end if;
		flag<= "00000000000000000000000000000000";
		tmp<=x(31) & "0000000000000000000000000000000";


	else
		tmp<=x;
		flag<='0';
		flag2<='0';
	end if;

--stage2
	if tmp(31) = '1' then

	    if flag2<='1' then
	       r<=(tmp(31 downto 23) + "000000001") & "00000000000000000000000" ;
            else
	       r<=tmp + flag;
	    end if;
	else

	       r<=tmp;
	end if;


	end if;
end process;

end architecture;


