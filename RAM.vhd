
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

USE work.PIC_pkg.all;

ENTITY RAM IS
PORT (
   Clk      : in    std_logic;
   Reset    : in    std_logic;
   write_en : in    std_logic;                          --Escritura en la RAM activa a nivel alto
   oe       : in    std_logic;                          --Lectura de la RAM activa a nivel bajo
   address  : in    std_logic_vector(7 downto 0);       --Dirección de la memoria
   databus  : inout std_logic_vector(7 downto 0);       --El databus
	Switches : out std_logic_vector(7 downto 0);        --salida directa del valor de los switches
	Temp_L : out std_logic_vector(6 downto 0);          --Valor del digito mas significativo del termostato en BCD
	Temp_H : out std_logic_vector(6 downto 0));         --Valor del digito menos significativo del termostato en BCD
END RAM;


ARCHITECTURE behavior OF RAM IS

  SIGNAL contents_RAM_esp: array8_RAM(63 downto 0);         --La RAM especifica
  SIGNAL contents_RAM_gen : array8_RAM(191 downto 0);       --La RAM generica restante

BEGIN

-------------------------------------------------------------------------
-- Memoria de propósito general
-------------------------------------------------------------------------

--Process que controla la RAM

p_RAM : process (Clk, Reset)  -- no reset
begin

        
    --Asignamos los valores por defecto despues del reset

	if Reset = '0' then       -- Reset asíncrono
		
		--address <= (others => 'Z');
		
    contents_RAM_esp(conv_Integer(DMA_RX_BUFFER_MSB))   <= X"00";
    contents_RAM_esp(conv_Integer(DMA_RX_BUFFER_MID))   <= X"00";
    contents_RAM_esp(conv_Integer(DMA_RX_BUFFER_LSB))   <= X"00";
    contents_RAM_esp(conv_Integer(NEW_INST))         <= X"00";
    contents_RAM_esp(conv_Integer(DMA_TX_BUFFER_MSB))   <= X"00";
    contents_RAM_esp(conv_Integer(DMA_TX_BUFFER_LSB))   <= X"00";
    --desde 06 hasta 0F reservado para ampliacion
    contents_RAM_esp(conv_integer(SWITCH_BASE))      <= X"00";
    contents_RAM_esp(conv_integer(SWITCH_BASE+1))      <= X"00";
    contents_RAM_esp(conv_integer(SWITCH_BASE+2))      <= X"00";
    contents_RAM_esp(conv_integer(SWITCH_BASE+3))      <= X"00";
    contents_RAM_esp(conv_integer(SWITCH_BASE+4))      <= X"00";
    contents_RAM_esp(conv_integer(SWITCH_BASE+5))      <= X"00";
    contents_RAM_esp(conv_integer(SWITCH_BASE+6))      <= X"00";
    contents_RAM_esp(conv_integer(SWITCH_BASE+7))      <= X"00";
    --desde 18 hasta 1F reservado para ampliacion
    contents_RAM_esp(conv_integer(LEVER_BASE))        <= X"00";
    contents_RAM_esp(conv_integer(LEVER_BASE+1))      <= X"00";
    contents_RAM_esp(conv_integer(LEVER_BASE+2))      <= X"00";
    contents_RAM_esp(conv_integer(LEVER_BASE+3))      <= X"00";
    contents_RAM_esp(conv_integer(LEVER_BASE+4))      <= X"00";
    contents_RAM_esp(conv_integer(LEVER_BASE+5))      <= X"00";
    contents_RAM_esp(conv_integer(LEVER_BASE+6))      <= X"00";
    contents_RAM_esp(conv_integer(LEVER_BASE+7))      <= X"00";
    contents_RAM_esp(conv_integer(LEVER_BASE+8))      <= X"00";
    contents_RAM_esp(conv_integer(LEVER_BASE+9))      <= X"00";
    --desde 2A hasta 30 reservado para ampliacion
    contents_RAM_esp(conv_integer(T_STAT))          <= X"12"; --Valor por defecto puesto por nosotros
    --desde 32 hasta 3F reservado para ampliacion
	
	--Reseteo de la ram
    	for i in 0 to 191 loop
			contents_RAM_gen(i) <= ext("0", 8);
		end loop;

  
	elsif Clk'event and Clk = '1' then
	
		-- Escribir
		if write_en = '1' then				
			if conv_Integer(address) <64 then                            --Si la address es menor que 64 pertenece a la RAM especifica
				--Esto estaria bien Especifica
				contents_RAM_esp(conv_Integer(address)) <= databus;
			else                                                         -- Si no es de la general    
				-- General
				contents_RAM_gen(conv_Integer(address)-64) <= databus; 
			end if;	
		end if;

  end if;

end process;

--Lectura de los valores pertenecientes a la RAM

process(contents_RAM_esp)
	begin
		-- Leer switch 
		for i in 0 to 7 loop
			Switches(i) <= contents_RAM_esp(conv_integer(SWITCH_BASE)+i)(0);
		end loop;
end process;

databus <= contents_RAM_esp(conv_integer(address)) when (oe = '0' and conv_Integer(address)<64) else (others => 'Z');
databus <= contents_RAM_gen(conv_integer(address)-64) when (oe = '0' and conv_Integer(address)>=64) else (others => 'Z');

-------------------------------------------------------------------------
-- Decodificador de BCD a 7 segmentos
-------------------------------------------------------------------------
with contents_RAM_esp(conv_Integer(T_STAT))(3 downto 0) select
Temp_L <=
    "0000110" when "0001",  -- 1
    "1011011" when "0010",  -- 2
    "1001111" when "0011",  -- 3
    "1100110" when "0100",  -- 4
    "1101101" when "0101",  -- 5
    "1111101" when "0110",  -- 6
    "0000111" when "0111",  -- 7
    "1111111" when "1000",  -- 8
    "1101111" when "1001",  -- 9
    "1110111" when "1010",  -- A
    "1111100" when "1011",  -- B
    "0111001" when "1100",  -- C
    "1011110" when "1101",  -- D
    "1111001" when "1110",  -- E
    "1110001" when "1111",  -- F
    "0111111" when others;  -- 0
	 
with contents_RAM_esp(conv_Integer(T_STAT))(7 downto 4) select
Temp_H <=
    "0000110" when "0001",  -- 1
    "1011011" when "0010",  -- 2
    "1001111" when "0011",  -- 3
    "1100110" when "0100",  -- 4
    "1101101" when "0101",  -- 5
    "1111101" when "0110",  -- 6
    "0000111" when "0111",  -- 7
    "1111111" when "1000",  -- 8
    "1101111" when "1001",  -- 9
    "1110111" when "1010",  -- A
    "1111100" when "1011",  -- B
    "0111001" when "1100",  -- C
    "1011110" when "1101",  -- D
    "1111001" when "1110",  -- E
    "1110001" when "1111",  -- F
    "0111111" when others;  -- 0
-------------------------------------------------------------------------

END behavior;

	