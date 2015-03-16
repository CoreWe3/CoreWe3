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

begin
	
   if rising_edge(clk) then


--stage1

	case x(30 downto 23) is  
	when "10010101" =>
		if x(0)='0' then
		   flag<="00000000000000000000000";
		   flag2<='0';
		else
		   flag<="00000000000000000000010";
		    if x(22 downto 1)="11111111111111111111111" then
			flag2<='1';

		    else
			flag2<='0';
		    end if;

		end if;
		tmp<= x(31 downto 1) & "0";

	when "10010100" =>

		if x(1 downto 0)="00" then
		   flag<="00000000000000000000000";
		   flag2<='0';
		else
		   flag<="00000000000000000000100";
		    if x(22 downto 2)="1111111111111111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31 downto 2) & "00";

	when "10010011" =>

		if x(2 downto 0)="000" then
		   flag<="00000000000000000000000";
		   flag2<='0';
		else
		   flag<="00000000000000000001000";
		    if x(22 downto 3)="111111111111111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31 downto 3) & "000";

	when "10010010" =>



		if x(3 downto 0)="0000" then
		   flag<="00000000000000000000000";
		   flag2<='0';
		else
		   flag<="00000000000000000010000";
		    if x(22 downto 4)="11111111111111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31 downto 4) & "0000";

	when "10010001" =>

		if x(4 downto 0)="00000" then
		   flag<="00000000000000000000000";
		   flag2<='0';
		else
		   flag<="00000000000000000100000";
		    if x(22 downto 5)="1111111111111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31 downto 5) & "00000";

	when "10010000" =>

		if x(5 downto 0)="000000" then
		   flag<="00000000000000000000000";
		   flag2<='0';
		else
		   flag<="00000000000000001000000";
		    if x(22 downto 6)="111111111111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31 downto 6) & "000000";

	when "10001111" =>

		if x(6 downto 0)="0000000" then
		   flag<="00000000000000000000000";
		   flag2<='0';
		else
		   flag<="00000000000000010000000";
		    if x(22 downto 7)="11111111111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31 downto 7) & "0000000";


	when "10001110" =>

		if x(7 downto 0)="00000000" then
		   flag<="00000000000000000000000";
		   flag2<='0';
		else
		   flag<="00000000000000100000000";
		    if x(22 downto 8)="1111111111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31 downto 8) & "00000000";


	when "10001101" =>

		if x(8 downto 0)="000000000" then
		   flag<="00000000000000000000000";
		   flag2<='0';
		else
		   flag<="00000000000001000000000";
		    if x(22 downto 9)="111111111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31 downto 9) & "000000000";

	when "10001100" =>

		if x(9 downto 0)="0000000000" then
		   flag<="00000000000000000000000";
		   flag2<='0';
		else
		   flag<="00000000000010000000000";
		    if x(22 downto 10)="1111111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31 downto 10) & "0000000000";



	when "10001011" =>


		if x(10 downto 0)="00000000000" then
		   flag<="00000000000000000000000";
		   flag2<='0';
		else
		   flag<="00000000000100000000000";
		    if x(22 downto 11)="111111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31 downto 11) & "00000000000";

	when "10001010" =>

		if x(11 downto 0)="000000000000" then
		   flag<="00000000000000000000000";
		   flag2<='0';
		else
		   flag<="00000000001000000000000";
		    if x(22 downto 12)="11111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31 downto 12) & "000000000000";

	when "10001001" =>

		if x(12 downto 0)="000000000000" then
		   flag<="00000000000000000000000";
		   flag2<='0';
		else
		   flag<="00000000010000000000000";
		    if x(22 downto 13)="11111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31 downto 13) & "0000000000000";

	when "10001000" =>

		if x(13 downto 0)="0000000000000" then
		   flag<="00000000000000000000000";
		   flag2<='0';
		else
		   flag<="00000000100000000000000";
		    if x(22 downto 14)="1111111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31 downto 14) & "00000000000000";

	when "10000111" =>

		if x(14 downto 0)="00000000000000" then
		   flag<="00000000000000000000000";
		   flag2<='0';
		else
		   flag<="00000001000000000000000";
		    if x(22 downto 15)="11111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31 downto 15) & "000000000000000";

	when "10000110" =>

		if x(15 downto 0)="000000000000000" then
		   flag<="00000000000000000000000";
		   flag2<='0';
		else
		   flag<="00000010000000000000000";
		    if x(22 downto 16)="1111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31 downto 16) & "0000000000000000";

	when "10000101" =>

		if x(16 downto 0)="0000000000000000" then
		   flag<="00000000000000000000000";
		   flag2<='0';
		else
		   flag<="00000100000000000000000";
		    if x(22 downto 17)="111111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31 downto 17) & "00000000000000000";

	when "10000100" =>

		if x(17 downto 0)="00000000000000000" then
		   flag<="00000000000000000000000";
		   flag2<='0';
		else
		   flag<="00001000000000000000000";
		    if x(22 downto 18)="11111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31 downto 18) & "000000000000000000";


	when "10000011" =>

		if x(18 downto 0)="000000000000000000" then
		   flag<="00000000000000000000000";
		   flag2<='0';
		else
		   flag<="00010000000000000000000";
		    if x(22 downto 19)="1111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31 downto 19) & "0000000000000000000";



	when "10000010" =>

		if x(19 downto 0)="0000000000000000000" then
		   flag<="00000000000000000000000";
		   flag2<='0';
		else
		   flag<="00100000000000000000000";
		    if x(22 downto 20)="111" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31 downto 20) & "00000000000000000000";

	when "10000001" =>

		if x(20 downto 0)="00000000000000000000" then
		   flag<="00000000000000000000000";
		   flag2<='0';
		else
		   flag<="01000000000000000000000";
		    if x(22 downto 21)="11" then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31 downto 21) & "000000000000000000000";

	when "10000000" =>

		if x(21 downto 0)="000000000000000000000" then
		   flag<="00000000000000000000000";
		   flag2<='0';
		else
		   flag<="10000000000000000000000";
		    if x(22)='1' then
			flag2<='1';
		    else
			flag2<='0';
		    end if;
		end if;
		tmp<= x(31 downto 22) & "0000000000000000000000";
	when "01111111" =>

		if x(22 downto 0)="000000000000000000000" then
		   flag2<='0';
		else
		   flag2<='1';
		end if;
		flag<="00000000000000000000000";
		tmp<= x(31 downto 23) & "00000000000000000000000";
	when others =>
	 if x(30)='0' then
		flag2<='0';
		flag<= "00000000000000000000000";
		if x(31)='1' then
		   if x(30 downto 0)="0000000000000000000000000000000" then
			tmp<="10000000000000000000000000000000";
			
		   else
			tmp<="10111111100000000000000000000000";
		   end if;
		else
		   tmp <= "00000000000000000000000000000000";
                end if;

	else
		tmp<=x;
		flag<="00000000000000000000000";
		flag2<='0';
	end if;
       end case;
	
--stage2
	if tmp(31) = '1' then

	    if flag2='1' then
	       r<=(tmp(31 downto 23) + "000000001") & "00000000000000000000000";
            else
	       r<=tmp + flag;
	    end if;
	else

	       r<=tmp;
	end if;

   end if;
end process;

end architecture;


