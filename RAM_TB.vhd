--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:35:33 11/18/2016
-- Design Name:   
-- Module Name:   C:/Users/migue/Desktop/Miguel/Universidad/4CUARTO/DSED/PIC_microcontroller/RAM_TB.vhd
-- Project Name:  PIC_microcontroller
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ram
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
 
ENTITY RAM_TB IS
END RAM_TB;
 
ARCHITECTURE behavior OF RAM_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ram
    PORT(
         Clk : IN  std_logic;
         Reset : IN  std_logic;
         write_en : IN  std_logic;
         oe : IN  std_logic;
         address : IN  std_logic_vector(7 downto 0);
         databus : INOUT  std_logic_vector(7 downto 0);
         Switches : OUT  std_logic_vector(7 downto 0);
         Temp_L : OUT  std_logic_vector(6 downto 0);
         Temp_H : OUT  std_logic_vector(6 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal Clk : std_logic := '0';
   signal Reset : std_logic := '0';
   signal write_en : std_logic := '0';
   signal oe : std_logic := '0';
   signal address : std_logic_vector(7 downto 0) := (others => '0');

	--BiDirs
   signal databus : std_logic_vector(7 downto 0);

 	--Outputs
   signal Switches : std_logic_vector(7 downto 0);
   signal Temp_L : std_logic_vector(6 downto 0);
   signal Temp_H : std_logic_vector(6 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ram PORT MAP (
          Clk => Clk,
          Reset => Reset,
          write_en => write_en,
          oe => oe,
          address => address,
          databus => databus,
          Switches => Switches,
          Temp_L => Temp_L,
          Temp_H => Temp_H
        );

  -- Clock generator
	PROCESS
	BEGIN
		Clk <= '1', '0' after 25 ns;
		wait for 50 ns;
	END PROCESS;

   -- Stimulus process
   stim_proc: process
   begin	
		reset<= '0', '1' after 2500 ns;

		write_en <= '1' , '0' after 20000 ns;
		oe <= '1', '0' after 30000 ns;
		
		address <= X"cc", X"10" after 5000 ns, X"12" after 10000 ns, X"14" after 15000 ns, X"cc" after 30000 ns; -- 31
		databus <= X"1a", X"01" after 5000 ns, X"01" after 10000 ns, X"01" after 15000 ns, "ZZZZZZZZ" after 20000 ns;

      wait;
   end process;

END;
