----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:21:18 10/21/2016 
-- Design Name: 
-- Module Name:    ShiftRegister - Behavioral 
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
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ShiftRegister is
    Port ( Reset : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           Enable : in  STD_LOGIC;						-- Señal activa a nivel alto que inicia la actividad del modulo.
           D : in  STD_LOGIC;								-- Señal de Datos de entrada en serie.
           Q : out  STD_LOGIC_VECTOR (7 downto 0));--	Señal de Datos de salida en paralelo.
end ShiftRegister;

architecture Behavioral of ShiftRegister is

signal cnt : STD_LOGIC_VECTOR(2 downto 0):="000"; 	-- Señal auxiliar que recorre los indices para dar a la salida.

begin
	process(Clk, Reset)
	begin
		if Reset = '0' then									-- Reset asincrono.
			Q <= "00000000";
			cnt <= "000";

		elsif Clk'event and Clk = '1' then				-- Para cada ciclo de reloj
			if Enable = '1' then								-- Cuando la señal de Enable esté activa
				Q(CONV_INTEGER(cnt)) <= D;					-- Se toma el valor actual de D y se introduce en el indice 
				cnt <= cnt + '1';								-- 	correspondiente de Q.			
				if cnt = "111" then							-- Se aumenta la cuenta y cuando esta llega a 7 se resetea.
					cnt <= "000";
				end if;
			end if;
		end if;
	end process;
														
end Behavioral;

