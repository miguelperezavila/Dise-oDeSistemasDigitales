--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:14:54 11/10/2016
-- Design Name:   
-- Module Name:   C:/Users/dsed06/Practica2/PracticaRS232/Shift_TB.vhd
-- Project Name:  PracticaRS232
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ShiftRegister
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
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY Shift_TB IS
END Shift_TB;
 
ARCHITECTURE behavior OF Shift_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ShiftRegister
    PORT(
         Reset : IN  std_logic;
         Clk : IN  std_logic;
         Enable : IN  std_logic;
         D : IN  std_logic;
         Q : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal Reset : std_logic := '0';
   signal Clk : std_logic := '0';
   signal Enable : std_logic := '0';
   signal D : std_logic := '0';

 	--Outputs
   signal Q : std_logic_vector(7 downto 0);


 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ShiftRegister PORT MAP (
          Reset => Reset,
          Clk => Clk,
          Enable => Enable,
          D => D,
          Q => Q
        );
		  
  -- Clock generator
PROCESS
  BEGIN
     Clk <= '1', '0' after 25 ns;
     wait for 50 ns;
  END PROCESS;
  
     -- Reset & Start generator
PROCESS
  BEGIN
     Reset <= '0', '1' after 75 ns;
	  D <= '1',
						'0' after 500 ns,    -- StartBit
			  '1' after 9150 ns,   -- LSb
           '0' after 17800 ns,
           '0' after 26450 ns,
           '1' after 35100 ns,
           '1' after 43750 ns,
           '1' after 52400 ns,
           '1' after 61050 ns,
           '0' after 69700 ns,  -- MSb
						'1' after 78350 ns,  -- Stopbit
						'1' after 87000 ns;
     Enable <= '0',

           '1' after 13475 ns,
			  '0' after 13525 ns,
           '1' after 22125 ns,
			  '0' after 22175 ns,
           '1' after 30775 ns,
			  '0' after 30825 ns,
           '1' after 39425 ns,
			  '0' after 39475 ns,
           '1' after 48075 ns,
			  '0' after 48125 ns,
           '1' after 56725 ns,
			  '0' after 56775 ns,
           '1' after 65375 ns,
			  '0' after 65425 ns;-- MSb
                    
     wait;
 end PROCESS;




END;
