LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

use work.PIC_pkg.ALL;

USE work.all;

entity  Etapa2 is
  port (      
		Reset     : in  std_logic;
      Clk       : in  std_logic;		
      TD        : out std_logic;
      RD        : in  std_logic;	
		DMA_RQ : out  STD_LOGIC;
		DMA_ACK : in  STD_LOGIC;	
		Send_comm : in  STD_LOGIC;
		Databus : INOUT std_logic_vector(7 downto 0);
		READY : out  STD_LOGIC);
		
end  Etapa2;
architecture Behavioral of Etapa2 is


  component RS232top
    port (
      Reset     : in  std_logic;
      Clk       : in  std_logic;
      Data_in   : in  std_logic_vector(7 downto 0);
      Valid_D   : in  std_logic;
      Ack_in    : out std_logic;
      TX_RDY    : out std_logic;
      TD        : out std_logic;
      RD        : in  std_logic;
      Data_out  : out std_logic_vector(7 downto 0);
      Data_read : in  std_logic;
      Full      : out std_logic;
      Empty     : out std_logic);
  end component;
  
  component DMA 
    Port ( Reset : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           RCVD_Data : in  STD_LOGIC_VECTOR (7 downto 0);
           RX_Full : in  STD_LOGIC; --
           RX_Empty : in  STD_LOGIC;
           Data_Read : out  STD_LOGIC;
           ACK_Out : in  STD_LOGIC;
           TX_RDY : in  STD_LOGIC;
           Valid_D : out  STD_LOGIC;
           TX_Data : out  STD_LOGIC_VECTOR (7 downto 0);
           Address : out  STD_LOGIC_VECTOR (7 downto 0);
           Databus : inout  STD_LOGIC_VECTOR (7 downto 0);
           Write_en : out  STD_LOGIC;
           OE : out  STD_LOGIC;
           DMA_RQ : out  STD_LOGIC;
           DMA_ACK : in  STD_LOGIC;
           Send_comm : in  STD_LOGIC;
           READY : out  STD_LOGIC);
end component;

component RAM IS
	port (
		Clk      : in    std_logic;
		Reset    : in    std_logic;
		write_en : in    std_logic;
		oe       : in    std_logic;
		address  : in    std_logic_vector(7 downto 0);
		databus  : inout std_logic_vector(7 downto 0);
		Switches : out std_logic_vector(7 downto 0);
		Temp_L : out std_logic_vector(6 downto 0);
		Temp_H : out std_logic_vector(6 downto 0));
end component;

 -- Señales 
 signal Valid_D, Ack_out, TX_RDY, Data_read, RX_Full, RX_Empty, Write_en, OE,
				RAM_Write, RAM_OE, DMA_READY, FlagZ, FlagC, FlagN, FlagE: STD_LOGIC;
 signal TX_Data, RCVD_Data, Address, RAM_Addr, Index_Reg, Switches: STD_LOGIC_VECTOR(7 downto 0);
 signal Instruction, Program_counter, ROM_Data, ROM_Addr : STD_LOGIC_VECTOR(11 downto 0);
 signal Temp_L, Temp_H : std_logic_vector(6 downto 0);
 signal Alu_op: alu_op;
 
 begin  -- behavior

  RS232_PHY: RS232top
    port map (
        Reset     => Reset,
        Clk       => Clk,
        Data_in   => TX_Data,
        Valid_D   => Valid_D,
        Ack_in    => Ack_out,
        TX_RDY    => TX_RDY,
        TD        => TD,
        RD        => RD,
        Data_out  => RCVD_Data,
        Data_read => Data_read,
        Full      => RX_Full,
        Empty     => RX_Empty
		  );
	
	DMA_map: DMA
		port map ( 
			  Reset => Reset,
           Clk => Clk,
           RCVD_Data => RCVD_Data,
           RX_Full => RX_Full,
           RX_Empty => RX_Empty,
           Data_Read => Data_Read,
           ACK_Out => Ack_out,
           TX_RDY => TX_RDY,
           Valid_D => Valid_D,
           TX_Data => TX_Data,
           Address => Address,
           Databus => Databus,
           Write_en => Write_en,
           OE => OE,
           DMA_RQ => DMA_RQ,
           DMA_ACK => DMA_ACK,
           Send_comm => Send_comm,
           READY => READY
			  );
		
	RAM_map: RAM 
		port map(
			Clk => Clk,
			Reset => Reset,
			write_en => write_en,
			oe       => OE,
			address => address,
			databus => databus,
			Switches => Switches,
			Temp_L =>  Temp_L,
			Temp_H => Temp_H
			);

end behavioral;

