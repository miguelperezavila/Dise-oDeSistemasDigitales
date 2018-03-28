----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:58:16 12/12/2016 
-- Design Name: 
-- Module Name:    RS232_RX - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RS232_RX is
    Port ( Reset : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           LineRD_in : in  STD_LOGIC;
           Valid_out : out  STD_LOGIC;
           Code_out : out  STD_LOGIC;
           Store_out : out  STD_LOGIC);
end RS232_RX;

architecture Behavioral of RS232_RX is

	type state_type is (Idle, StartBit, RcvData, StopBit);
	signal next_state : state_type;
	signal state : state_type:= Idle;
	
	signal en_Counter, en_Count_RX : std_logic;
	
	signal Valid_Out_aux, code_Out_aux, Store_Out_aux : std_logic;
	
	signal cnt_Counter : integer range 0 to 255;
	signal cnt_Count_RX : integer range 0 to 15;
	
	constant EndPulseWidth : integer:= 173;
	constant EndCount : integer:=8;
	

begin

	process( state, LineRD_in, cnt_Counter, cnt_Count_RX)
		begin
		
		
		next_state <= state;
		Valid_Out_aux <= '0';
		Code_Out_aux <= '0';
		Store_Out_aux <= '0';
		en_Counter <= '0';
		en_Count_RX <= '0';
		
		
		case state is
		
			when Idle =>
				Valid_Out_aux <= '0';
				Code_Out_aux <= '0';
				Store_Out_aux <= '0';
				en_Counter <= '0';
				
				if LineRD_in = '0' then
					next_state <= StartBit;
				end if;

			when StartBit =>
				en_Counter <= '1';
				Valid_Out_aux <= '0';
				Code_Out_aux <= '0';
				Store_Out_aux <= '0';
				if cnt_Counter = EndPulseWidth then
					next_state <= RcvData;
				end if;
				
			when RcvData =>
				Valid_Out_aux <= '0';
				Code_Out_aux <= LineRD_in;
				Store_Out_aux <= '0';
				en_Count_RX <= '1';
				en_Counter <= '1';
				if cnt_Counter = EndPulseWidth/2 then
					Valid_Out_aux <= '1';
					--Code_Out_aux <= LineRD_in;
				end if;
				if (cnt_Count_RX = (EndCount - 1) and cnt_Counter = EndPulseWidth )then
					next_state <= StopBit;
				end if;
			
			when StopBit =>
				Valid_Out_aux <= '0';
				Code_Out_aux <= '0';
				Store_Out_aux <= '0';
				en_Count_RX <= '0';
				en_Counter <= '1';
				if cnt_Counter = EndPulseWidth then
					Store_Out_aux <= '1';
					next_state <= Idle;
				end if;
			
		end case;
	end process;
	
	process(Clk, Reset)
	begin
		if Reset = '0' then
			state <= Idle;
			elsif Clk'event and Clk='1' then
		
			state <= next_state;
			
			if en_Counter = '1' then
				cnt_Counter <= cnt_Counter + 1;
				if cnt_Counter = EndPulseWidth then
					if en_Count_RX = '1' then
						if cnt_Count_RX < EndCount then
						cnt_Count_RX <= cnt_Count_RX + 1;
						else cnt_Count_RX <= 0;
						end if;
					else cnt_Count_Rx <= 0;
					end if;
					cnt_Counter <= 0;
				end if;
			else 
				cnt_Counter <= 0;
			end if;
			
			if en_Count_RX = '0' then
				cnt_Count_RX <= 0;
			end if;
		end if;
		
	end process;
		Valid_out <= Valid_Out_aux;
		Code_out <= Code_Out_aux;
		Store_out <= Store_Out_aux;
		
end Behavioral;

