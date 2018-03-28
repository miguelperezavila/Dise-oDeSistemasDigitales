--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:46:11 11/29/2016
-- Design Name:   
-- Module Name:   C:/Users/David/Dropbox/Electronica 1 semestre/DSED/Practicas/PIC_microcontroller/DMA_tb.vhd
-- Project Name:  PIC_microcontroller
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Etapa2
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.PIC_pkg.ALL;
USE work.RS232_test.all;
 
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY DMA_tb IS
END DMA_tb;
 
ARCHITECTURE behavior OF DMA_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Etapa2
    PORT(
         Reset : IN  std_logic;
         Clk : IN  std_logic;
         TD : OUT  std_logic;
         RD : IN  std_logic;
         DMA_RQ : OUT  std_logic;
         DMA_ACK : IN  std_logic;
         Send_comm : IN  std_logic;
         READY : OUT  std_logic;
			Databus : INOUT std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal Reset : std_logic := '0';
   signal Clk : std_logic := '0';
   signal RD : std_logic := '0';
   signal DMA_ACK : std_logic := '0';
   signal Send_comm : std_logic := '0';

 	--Outputs
   signal TD : std_logic;
   signal DMA_RQ : std_logic;
   signal READY : std_logic;

   -- Clock period definitions
   constant Clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Etapa2 PORT MAP (
          Reset => Reset,
          Clk => Clk,
          TD => TD,
          RD => RD,
          DMA_RQ => DMA_RQ,
          DMA_ACK => DMA_ACK,
          Send_comm => Send_comm,
          READY => READY
        );

-----------------------------------------------------------------------------
-- Clock generator
-----------------------------------------------------------------------------

  p_clk : PROCESS
  BEGIN
     Clk <= '1', '0' after 25 ns;
     wait for 50 ns;
  END PROCESS;
  
-----------------------------------------------------------------------------
-- Stimulus process
-----------------------------------------------------------------------------
   
process
   begin		
	
	Reset <= '0', '1' after 50 ns;
  
   DMA_ACK <= '1' after 186750 ns, '0' after 186800 ns, '1' after 393500 ns, '0' after 393550 ns, '1' after 600300 ns, '0' after 600350 ns;
	-- '0', '1' after 100 us, '0' after 1000 us ;--
  
   Send_comm <= '0', '1' after 800 us, '0' after 800050 ns;--, '1' after 826 ns, '0' after 876 ns;
	
	RD <= '1';
	wait for 100 us;
	Transmit(RD, "01001001"); -- I
	wait for 120 us;
	Transmit(RD, "00110010"); -- 4
	wait for 120 us;
	Transmit(RD, "00110001"); --1
   wait;
	
end process;



END;
