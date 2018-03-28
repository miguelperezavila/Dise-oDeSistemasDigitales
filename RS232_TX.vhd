-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:58:01 12/12/2016 
-- Design Name: 
-- Module Name:    RS232_TX - Behavioral 
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
use IEEE.numeric_std.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RS232_TX is
    Port ( Reset : in  STD_LOGIC;							-- 
           Clk : in  STD_LOGIC;
           Start : in  STD_LOGIC;							-- Señal que da comienzo a la transmision, activa a nivel alto.
           Data : in  STD_LOGIC_VECTOR (7 downto 0);	-- Bus de datos a transmitir.
           EOT : out  STD_LOGIC;								-- Comunica si el transmisor esta ocioso ('1') u ocupado ('0').
           TX : out  STD_LOGIC);								-- Linea por la que transmite la informacion (1 pulso de start, 1 de
end RS232_TX;														--		stop y 8 de informacion.

 architecture Behavioral of RS232_TX is
 
	-- Enumerado de la maquina de estados.
	type state_type is (Idle, StartBit, SendData, StopBit); 
	signal next_state : state_type;							-- Estado siguiente
	signal state : state_type:= Idle;						-- Estado actual
	
	--SALIDAS AUXILIARES;
	signal EOT_aux, TX_aux : std_logic;
	
	signal en_Count, en_Pulse : std_logic;
	
	signal cnt_Count : integer range 0 to 15 :=0;		-- Señal para ver el indice del valor que se esta mandando (0-7)
	signal cnt_Pulse : integer range 0 to 255 :=0;		-- Señal para ver la longitud del pulso
	
	-- Constantes que delimitan la longitud del pulso y los indices que se mandan.
	constant PulseEndWidth : integer:= 174;
	constant EndCount : integer:= 8;

begin

process(state, Start, cnt_Pulse, cnt_Count, Data)
begin

	--Valores por defecto
	next_state <= state;						-- Mantiene el estado, deja a '1' la linea de transmisión, dice que esta ocioso el  
	TX_aux <= '1';								-- 	transmisor y apaga la cuenta de pulsos e indices.
	EOT_aux <= '1';
	en_Pulse <= '0';
	en_Count <= '0';
	
	case state is
	
	-- Estado de reposo.
		when Idle =>
			TX_aux <= '1';						-- Deja a '1' la linea de transmisión, dice que esta ocioso el transmisor
			EOT_aux <= '1';					-- 	 y cuando recibe la señal Start, pasa al estado StartBit y pasa a estar
			if Start = '1' then				-- 	 ocupado el transmisor y activa la cuenta de pulsos.
				next_state <= StartBit;
				EOT_aux <= '0';
				en_Pulse <= '1';
			end if;
			
	-- Estado para mandar el bit de comienzo.
		when StartBit =>						
			en_Pulse <= '1';					-- Deja habilitada la cuenta de pulsos, sigue ocupado y manda durante un pulso
			EOT_aux <= '0';					-- 	un '0' que es el bit de comienzo, cuando termina la cuenta de pulsos, 
			TX_aux<='0';						-- 	pasa al estado SendData.
			if cnt_Pulse = 174 then 
				next_state <= SendData;
			end if;
	
	-- Estado para mandar los datos.
		when SendData => 
			EOT_aux <= '0';					-- Sigue ocupado, habilita la cuenta de pulsos y de indices de datos, 
			en_Pulse <= '1';					-- 	mientas los indices sean menores que 8 se manda por la linea de transmision
			en_Count <= '1';					--		el dato en el indice dado, al terminar la cuenta vamos al estado StopBit.
			if cnt_Count < EndCount then	
				TX_aux <= Data(cnt_Count);
			elsif cnt_Count = EndCount then
				next_state <= StopBit;
			end if;
			
	-- Estado para mandar el bit de final.
		when StopBit =>
													-- Sigue ocupado, manda por la linea el bit de parada, un '1', termina la cuenta de
			TX_aux <= '1';						-- 	indices y mantiene activa la cuenta de pulsos. Al terminar, vuelve al estado
			EOT_aux <= '0';					-- 	Idle.
			en_Count <= '0';
			en_Pulse <= '1';
			
			if cnt_Pulse = PulseEndWidth then
				next_state<= Idle;
			end if;
		
	end case;
end process;

process(Clk, Reset)
	begin
		if Reset = '0' then					-- Reset Asincrono.
			state <= Idle;
		elsif Clk'event and Clk='1' then
		
			state <= next_state;				-- Cada ciclo de reloj actualiza el estado actual.
			
			if en_Pulse = '1' then			-- Cuenta de pulsos, va de 0 a 174 ciclos de reloj.
				cnt_Pulse <= cnt_Pulse + 1;			
			else cnt_Pulse <= 0;			
			end if;
														
			if cnt_Pulse = PulseEndWidth then	-- Cuenta de indices, por cada pulso finalizado si la cuenta de indices esta
				cnt_Pulse <= 0;						--  	activa, esta suma 1, va de 0 a 7.
				if en_Count = '1' then
					cnt_Count <= cnt_Count + 1;
				else 	
					cnt_Count <= 0;					-- Cuando en_Count es cero y la cuenta de Pulsos ha concluido, se reseta la				
				end if;									-- 	cuenta indices.
			end if;
			
			if en_Count = '0' then					-- Cuando se apaga la cuenta de indices, esta se resetea.
				cnt_Count <= 0;
			end if;

		end if;
	end process;


	EOT <= EOT_aux;					-- Se ponen las señales auxiliares a la salida del modulo.
	TX  <= TX_aux;
	
end Behavioral;

