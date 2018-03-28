----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:58:59 12/03/2016 
-- Design Name: 
-- Module Name:    ALU - Behavioral 
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

entity ALU is
    Port ( Reset : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           Alu_op : in alu_op;									--El tipo de instruccón que entra
           Databus : inout  STD_LOGIC_VECTOR (7 downto 0);		--El databus
			  Index_Reg : out std_logic_vector(7 downto 0);		--Index register 
           FlagZ : out  STD_LOGIC;								--Flag de cuando la operacion da 0
           FlagC : out  STD_LOGIC;
           FlagN : out  STD_LOGIC;
           FlagE : out  STD_LOGIC);
end ALU;

architecture Behavioral of ALU is

		signal Acc, Index, RegA, RegB : STD_LOGIC_VECTOR(7 downto 0); 		--Registros de funcionamiento de la ALU
		
		--	Mejora --
		signal Acc_save : STD_LOGIC_VECTOR(7 downto 0);
		
begin
	
	--Process que controla la ALU. En la lista de sensibilidad esta el CLK, un Reset y el tipo de operación.
	process(Clk, Reset, Alu_op)
		begin
			
			--Reset asíncrono que pone todos los valores por defecto.
			if Reset = '0' then
				FlagZ <= '0';
				FlagC <= '0';
				FlagN <= '0';
				FlagE <= '0';
				-- Databus <= (others => 'Z');
				-- Index_Reg <= "ZZZZZZZZ";
				Acc <= X"00";
				Index <= X"00";
				RegA <= X"00";
				RegB <= X"00";
				
				
			elsif Clk'event and Clk='1' then	--Para cada evento de subida del CLK comienza el case del tipo de ALU_OP
				case Alu_op is
					
					--Cuando no se recibe ninguna operación se ponen los valores por defecto
					when nop =>
					
						RegA <= RegA;
						RegB <= RegB;
						Acc <= Acc;
						Index <= Index;
					--Operación de carga de un valor procedente del Databus en el Registro A	
					when op_lda =>
						RegA <= Databus;
					--Operación de carga de un valor procedente del Databus en el Registro  B
					when op_ldb =>
						RegB <= Databus;
					--Operación de carga de un valor procedente del Databus en el Acumulador
					when op_ldacc =>
						Acc <= Databus;
					--Operación de carga de un valor procedente del Databus en el Index
					when op_ldid =>
						Index <= Databus;
					--Carga de un valor guardado en el ACC al Index	
					when op_mvacc2id =>
						Index <= Acc;
					--Carga de un valor guardado en el ACC en el Registro A
					when op_mvacc2a =>
						RegA <= Acc;
					--Carga de un valor guardado en el ACC en el Registro B	
					when op_mvacc2b =>
						RegB <= Acc;
					
					--Suma de los valores guardados en el Registro A y B y puestos en el Acumulador
					--Si el acumulador despues de la operación es cero se activa el FlagZ
					when op_add =>
						
						Acc <= RegA + RegB;
						if Acc = 0 then
							FlagZ <= '1';
						elsif Acc > 0 then
							FlagZ <= '0';
						end if;
					--Resta de los valores guardados en el Registro A y B y puestos en el Acumulador
					--Si el acumulador despues de la operación es cero se activa el FlagZ				
					when op_sub =>
						Acc <= RegA - RegB;
						if Acc = 0 then
							FlagZ <= '1';
						elsif Acc > 0 then
							FlagZ <= '0';
						end if;
					--Desplazamiento del valor guardado en el acumulador a la izquierda
					--Y guardado en el acumulador
					when op_shiftl =>
						Acc <= Acc(6 downto 0) & '0';

					--Desplazamiento del valor guardado en el acumulador a la derecha
					--Y guardad en el acumulador
					when op_shiftr =>
						Acc <= '0' & Acc(7 downto 1);
					--Operación AND de los valores de los registros A y B y guardados en el ACC
					-- Si el resultado de la operación es cero se activa el FlagZ
					when op_and =>
						Acc <= RegA and RegB;
						if Acc = 0 then
							FlagZ <= '1';
						elsif Acc > 0 then
							FlagZ <= '0';
						end if;
 					--Operación OR de los valores de los registros A y B y guardados en el ACC
					-- Si el resultado de la operación es cero se activa el FlagZ
					when op_or =>
						Acc <= RegA or RegB;
						if Acc = 0 then
							FlagZ <= '1';
						elsif Acc > 0 then
							FlagZ <= '0';
						end if;
					--Operación XOR de los valores de los registros A y B y guardados en el ACC
					-- Si el resultado de la operación es cero se activa el FlagZ
					when op_xor =>
						Acc <= RegA xor RegB;
						if Acc = 0 then
							FlagZ <= '1';
						elsif Acc > 0 then
							FlagZ <= '0';
						end if;
					--Operación de comparación de los registros A y B
					--si son iguales se activa el FlagZ
					when op_cmpe =>
						if RegA = RegB then
							FlagZ <= '1';
						else
							FlagZ <= '0';
						end if;
					--Operación de comparacion de los registros A y B
					--Si B es mayor que A se activa el FlagZ
					when op_cmpl =>
						if RegA < RegB then
							FlagZ <= '1';
						else
							FlagZ <= '0';
						end if;
					--Operación de comparacion de los registros A y B
					--Si B es menor que A se activa el FlagZ
					when op_cmpg =>
						if RegA > RegB then
							FlagZ <= '1';
						else
							FlagZ <= '0';
						end if;
					
					--Operacion de cambio de ascii a binario del valor guardado en el registro A
					when op_ascii2bin =>
						if RegA >=  48 and RegA <= 57 then
							Acc <= RegA - 48;
						else
							Acc <= X"FF"; 
						end if;
						
					--Operación de cambio de binario a ascii del valor guardado en el registro A
					when op_bin2ascii =>
						if RegA >=  0 and RegA <= 9 then
							Acc <= RegA + 48;
						else
							Acc <= X"FF"; 
						end if;
						
					when op_oeacc =>
						--Databus <= Acc;
						
					--	Mejora	--
					when op_save =>
						Acc_save <= Acc;
						
					when op_restore =>
						Acc <= Acc_save;
					
				end case;			
			end if;			
	end process;
	
	--Escritura en el Registro Index
	Index_Reg <= Index;
	--Cuando alu_op es op_oeacc se escribe en el databus el valor del ACC.
Databus <= Acc when (Alu_op = op_oeacc) else (others => 'Z');

end Behavioral;

