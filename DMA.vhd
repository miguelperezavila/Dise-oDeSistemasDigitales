----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:48:19 11/22/2016 
-- Design Name: 
-- Module Name:    DMA - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.PIC_pkg.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DMA is
    Port ( Reset : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           RCVD_Data : in  STD_LOGIC_VECTOR (7 downto 0);		-- Dato recibido por la linea RS232
           RX_Full : in  STD_LOGIC; 									-- Señal que indica que la memoria interna esta llena.
           RX_Empty : in  STD_LOGIC;									-- Señal que indica que la memoria interna esta vacia.
           Data_Read : out  STD_LOGIC;									-- Peticion de lectura de un nuevo dato.
           ACK_Out : in  STD_LOGIC;										-- Señal de reconocimiento de la petición de lectura 
           TX_RDY : in  STD_LOGIC;								 		-- Señal que dice si el transmisor esta ocioso.
           Valid_D : out  STD_LOGIC;									-- Validación del dato enviado al transmisor RS232 
           TX_Data : out  STD_LOGIC_VECTOR (7 downto 0);			-- Dato para enviar por línea serie.
           Address : out  STD_LOGIC_VECTOR (7 downto 0);			-- Direcciones del bus de datos del sistema 
           Databus : inout  STD_LOGIC_VECTOR (7 downto 0);		-- Bus de datos del sistema
           Write_en : out  STD_LOGIC;									-- Indicación de escritura para la RAM
           OE : out  STD_LOGIC;											-- Habilitación de la salida de la RAM 
           DMA_RQ : out  STD_LOGIC;										-- Petición de buses al CPU
           DMA_ACK : in  STD_LOGIC;										-- Reconocimiento y préstamo de buses por parte del CPU 
           Send_comm : in  STD_LOGIC;									-- Señal de comienzo de envío de datos, controlada por el CPU
           READY : out  STD_LOGIC;										-- Señal que indica si la DMA esta ociosa.
			  -- 	Mejoras	--
			  int_RQ : out STD_LOGIC);			  
end DMA;

architecture Behavioral of DMA is
	
	-- Enumerado con los estados de la DMA.
		type state_type is (IDLE, RX, RX_MSB, RX_MID, RX_LSB, RX_NEW_INST,
										  TX, TX_MSB, TX_LSB, WAIT_TX_1, WAIT_TX_2);
		signal next_state : state_type;
		signal state : state_type:= IDLE;

		signal cnt_rx, cnt_rx_aux : STD_LOGIC_VECTOR(1 downto 0):= "00";  -- Contadores actual y proximo.

		
begin

process(state, next_state, RX_Empty, Send_comm, DMA_ACK, ACK_Out, TX_RDY, RCVD_Data, cnt_rx, Databus)
	begin
		-- Valores por defecto
				OE	 			<= 'Z';					-- Se ponen OE, Write_en, Address y Databus a alta impedancia mientras 
				Write_en 	<= 'Z';					-- 	no se utilicen por la DMA.
				Address		<= (others =>'Z');
				Databus 		<= (others =>'Z');
				DMA_RQ		<= '0';					-- No pide los buses
				Valid_D		<= '1';					-- No manda un dato al TX
				Data_Read	<= '0';					-- No pide leer del RX
				TX_Data 		<= "00000000"; 		-- No manda nada.
				READY 		<= '0'; 					-- Se encuentra ocupada por defecto.
				cnt_rx_aux 	<= cnt_rx;				-- Actualiza el valor de la cuenta.
				next_state 	<= state;				-- Actualiza el estado actual.
				--	Mejora	--
				int_RQ <= '0';
				
		case state is
		
		-- Estado de reposo.
			when IDLE =>
				READY			<= '1';					-- Ocioso, no esta haciendo nada
				if RX_Empty = '0' then 				-- Espera que la fifo no este vacia y pasa al estado RX.
					next_state <= RX;					
				elsif Send_comm = '1' then			-- Espera a recibir un comando y se pone en ocupado y pasa al estado TX.
					READY <= '0';
					next_state <= TX; 
				else
					next_state <= IDLE;				-- Mientras no reciba nada se queda en Idle.			
				end if;
----------------------------------------------------------------------------------------------------------------
--			RX			--
----------------------------------------------------------------------------------------------------------------
	
	-- Estado inicial de recepción.
			when RX => 
				DMA_RQ <= '1'; 						-- Pide los buses
				Data_Read <= '1';						-- Lee los datos de la linea RS232
				READY <= '0';							-- Se pone en ocupado.
				if DMA_ACK = '1' then				-- Cuando se le concedan los buses:
					case cnt_rx is						-- 	Transmite uno de los 3 Bytes en funcion de la cuenta.		
						when "00" =>
							next_state <= RX_MSB;
						when "01" =>
							next_state <= RX_MID;
						when "10" =>
							next_state <= RX_LSB;
						when others =>
					end case;
					elsif DMA_ACK = '0' then		-- Si no se le conceden espera en RX.
						next_state <= RX;
				end if;
		
		-- Estado de recepción del bit mas significativo.
			when RX_MSB =>
				cnt_rx_aux <= cnt_rx + '1';		-- Aumenta la cuenta.
				DMA_RQ <= '0'; 						-- Deja de pedir los buses.
				Address <= DMA_RX_BUFFER_MSB;		-- Manda la direccion del MSB
				Databus <= RCVD_Data;				-- Transmite el MSB por el Databus.
				Write_en <= '1';						-- Habilita la escritura de la RAM.
				Data_Read <= '0';						-- No pide leer del RX
				next_state <= IDLE;					-- Vuelve al estado IDLE.
		
		-- Estado de recepción del Byte central.
			when RX_MID =>		
				cnt_rx_aux <= cnt_rx + '1';		-- Aumenta la cuenta.
				DMA_RQ <= '0'; 						-- Deja de pedir los buses.
				Address <= DMA_RX_BUFFER_MID;		-- Manda la direccion del bit central
				Databus <= RCVD_Data;				-- Transmite el MID por el Databus.
				Write_en <= '1';						-- Habilita la escritura de la RAM.
				Data_Read <= '0';						-- No pide leer del RX
				next_state <= IDLE;					-- Vuelve al estado IDLE.
	
		-- Estado de recepción del Byte menos significativo.		
			when RX_LSB =>
				Address <= DMA_RX_BUFFER_LSB;		-- Manda la direccion del bit menos significativo
				Databus <= RCVD_Data;				-- Transmite el LSB por el Databus.
				Write_en <= '1';						-- Habilita la escritura de la RAM.
				Data_Read <= '0';						-- No pide leer del RX
				next_state <= RX_NEW_INST;			-- Va al estado RX_NEW_INST.
				
		--	Mejora	--
		-- Estado de recepción de una nueva instruccion.
			when RX_NEW_INST =>
				DMA_RQ <= '0'; 						-- Deja de pedir los buses.
				cnt_rx_aux <= "00";					-- Resetea la cuenta.
				int_RQ <= '1';
				next_state <= IDLE;					-- Vuelve al estado IDLE.

----------------------------------------------------------------------------------------------------------------
			--			TX			--
----------------------------------------------------------------------------------------------------------------
		
		-- Estado inicial de transmision.
			when TX =>
				next_state <= TX_MSB;				-- Va al estado TX_MSB
	
		-- Estado de transmision del Byte mas significativo
			when TX_MSB =>
				Address <= DMA_TX_BUFFER_MSB;		-- Mandamos a la RAM  la direccion del Byte mas significativo
				OE <= '0';								-- Habilitamos la salida de la RAM
				TX_Data <= Databus;					-- Enviamos la informacion actual del bus de datos.
				Valid_D <= '0';						-- No validamos el dato aun. 
				if ACK_Out = '1' then				-- Esperamos el reconociento de la peticion de lectura.
					next_state <= TX_MSB;			-- Vamos al estado TX_MSB.
				elsif ACK_Out = '0' then			-- Cuando se reconozca la peticion, 
					Valid_D <= '1';					-- Validamos el dato enviado
					next_state <= WAIT_TX_1;		-- Vamos al estado WAIT_TX_1
				end if;
		
		-- Estado de espera para transmitir el MSB 
			when WAIT_TX_1 =>							
				if TX_RDY = '1' then					-- Mientras el transmisor este ocupado, permanecer en el estado WAIT_TX_1 
					next_state <= WAIT_TX_1;
				elsif TX_RDY = '0' then				-- Cuando  el transmisor este ocioso ir al estado TX_LSB.
					next_state <= TX_LSB;
				end if;
		
		-- Estado de transmision del Byte menos significativo	
			when TX_LSB =>
				Address <= DMA_TX_BUFFER_LSB;			-- Mandamos a la RAM  la direccion del Byte menos significativo
				OE <= '0';									-- Habilitamos la salida de la RAM
				TX_Data <= Databus;						-- Enviamos la informacion actual del bus de datos. 
				Valid_D <= '0';							-- No validamos el dato aun. 
				if ACK_Out = '1' then					-- Esperamos el reconociento de la peticion de lectura.
					next_state <= TX_LSB;				-- Vamos al estado TX_LSB.
				elsif ACK_Out = '0' then				-- Cuando se reconozca la peticion, 
					Valid_D <= '1';						-- Validamos el dato enviado
					next_state <= WAIT_TX_2;			-- Vamos al estado WAIT_TX_2
				end if;
				
		-- Estado de espera para transmitir el MSB 	
			when WAIT_TX_2 =>
				if TX_RDY = '1' then						-- Mientras el transmisor este ocupado, permanecer en el estado WAIT_TX_2 
					next_state <= WAIT_TX_2;
				elsif TX_RDY = '0' then					-- Cuando  el transmisor este ocioso ir al estado Idle y comunicar que la
					READY <= '1';							-- 		DMA esta ociosa y volver al estado Idle
					next_state <= IDLE;
				end if;

			end case;
		end process;
		
----------------------------------------------------------------------------------------------------------------
			--			Reset 		--
----------------------------------------------------------------------------------------------------------------

	process(Clk, Reset)		
		begin
			if Reset = '0' then							-- Reset asincrono.
				cnt_rx <= "00";							-- Resetea la cuenta
				state <= IDLE;								-- Va al estado Idle.
			elsif Clk'event and Clk='1' then				
				cnt_rx <= cnt_rx_aux;					-- Actualiza el estado de la cuenta.
				state <= next_state;						-- Actualiza el estado actual.
			end if;
	end process;
						
end Behavioral;

