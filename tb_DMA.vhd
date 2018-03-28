--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:18:31 12/07/2015
-- Design Name:   
-- Module Name:   C:/Users/amadeo/Documents/Universidad/7 semestre/DSED/VHDL/p3/PIC_Completo/PIC_Completo/tb_DMA.vhd
-- Project Name:  PIC_Completo
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: DMA
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 -- File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top--level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post--implementation 
-- simulation model.
----------------------------------------------------------------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

use work.RS232_test.all;

USE work.PIC_pkg.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_DMA IS
END tb_DMA;
 
ARCHITECTURE behavior OF tb_DMA IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DMA
    PORT(
         Reset : in  STD_LOGIC;
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
        
    END COMPONENT;
   
   COMPONENT RS232top
    PORT(
      Reset     : in  std_logic;   -- Low_level--active asynchronous reset
      Clk       : in  std_logic;   -- System clock (20MHz), rising edge used
      Data_in   : in  std_logic_vector(7 downto 0);  -- Data to be sent
      Valid_D   : in  std_logic;   -- Handshake signal
                                 -- from guest system, low when data is valid
      Ack_in    : out std_logic;   -- ACK for data received, low once data
                                 -- has been stored
      TX_RDY    : out std_logic;   -- System ready to transmit
      TD        : out std_logic;   -- RS232 Transmission line
      RD        : in  std_logic;   -- RS232 Reception line
      Data_out  : out std_logic_vector(7 downto 0);  -- Received data
      Data_read : in  std_logic;   -- Data read for guest system
      Full      : out std_logic;   -- Full internal memory
      Empty     : out std_logic  -- Empty internal memory
    );
   END COMPONENT;
   
   COMPONENT RAM
    PORT(
      Clk      : in    std_logic;
      Reset    : in    std_logic;
      write_en : in    std_logic;
      oe       : in    std_logic;
      address  : in    std_logic_vector(7 downto 0);
      databus  : inout std_logic_vector(7 downto 0);
      Switches : out std_logic_vector(7 downto 0);
      Temp_L   : out std_logic_vector(6 downto 0);
      Temp_H  : out std_logic_vector(6 downto 0)
    );
    END COMPONENT;

   --Inputs
   signal DMA_ACK : std_logic;
   signal Send_comm : std_logic;
  signal Reset, Clk, ACK_out, TX_RDY, RD, RX_Empty, RX_Full : std_logic;
  signal RCVD_Data : std_logic_vector(7 downto 0);

  --BiDirs
   signal Databus : std_logic_vector(7 downto 0);

   --Outputs
   signal DMA_RQ : std_logic;
   signal READY : std_logic;
  signal Valid_D, TD, Data_read, Write_en, OE : std_logic;
  signal TX_Data : std_logic_vector(7 downto 0);
  signal Address : std_logic_vector(7 downto 0);
  signal Switches : std_logic_vector(7 downto 0);
  signal Temp_H, Temp_L : std_logic_vector(6 downto 0);
  -- Clock period definitions
   constant Clk_period : time := 50 ns;
  
  constant zz : std_logic_vector(7 downto 0) := (others =>'Z');

 
BEGIN
 
  -- Instantiate the Unit Under Test (UUT)
   DMA_pm: DMA PORT MAP (
          Reset => Reset,
          Clk => Clk,
          RCVD_Data => RCVD_Data,
          RX_Full => RX_Full,
          RX_Empty => RX_Empty,
          ACK_out => ACK_out,
          TX_RDY => TX_RDY,
          DMA_ACK => DMA_ACK,
          Send_comm => Send_comm,
          Databus => Databus,
          Data_Read => Data_Read,
          Valid_D => Valid_D,
          TX_Data => TX_Data,
          Address => Address,
          Write_en => Write_en,
          OE => OE,
          DMA_RQ => DMA_RQ,
          READY => READY
        );
      
  RS232top_pm: RS232top PORT MAP (
      Reset   => Reset,  
      Clk     => Clk,
      Data_in => TX_Data,
      Valid_D => Valid_D,                                
      Ack_in  => ACK_out,
      TX_RDY  => TX_RDY,
      TD      => TD,
      RD      => RD,
      Data_out   => RCVD_Data,
      Data_read   => Data_read,
      Full       => RX_Full,
      Empty      => RX_Empty
      );
      
  RAM_pm: RAM PORT MAP (
      Clk        => Clk,
      Reset      => Reset,
      write_en   => Write_en,
      oe         => OE,
      address    => Address,
      databus    => Databus,
      Switches   => Switches,
      Temp_L     => Temp_L,
      Temp_H    => Temp_H
      );

   -- Clock process definitions
   Clk_process :process
   begin
    Clk <= '0';
    wait for Clk_period/2;
    Clk <= '1';
    wait for Clk_period/2;
   end process;
 
  Reset <= '0', '1' after 80 ns;
  
  DMA_ACK <= '0', '1' after 100 us, '0' after 100050 ns, '1' after 300 us, '0' after 300050 ns, '1' after 500 us, '0' after 500050 ns;
  
  Send_comm <= '0', '1' after 826 ns, '0' after 876 ns;
  
  --Databus <= ZZ;
  
  process
  begin
    RD<='1';
    wait for 10 us;
    Transmit(RD, "10101110");
    wait for 100 us;
    Transmit(RD, "11001111");
    wait for 100 us;
    Transmit(RD, "01011001");
    wait;
  end process;
  
   

END;