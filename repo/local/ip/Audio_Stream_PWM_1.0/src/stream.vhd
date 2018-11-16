-------------------------------------------------------------------------------
--                                                                 
--  COPYRIGHT (C) 2014, Digilent RO. All rights reserved
--                                                                  
-------------------------------------------------------------------------------
-- FILE NAME            : i2s_stream.vhd
-- MODULE NAME          : I2S Stream
-- AUTHOR               : Hegbeli Ciprian
-- AUTHOR'S EMAIL       : ciprian.hegbeli@digilent.com
-------------------------------------------------------------------------------
-- REVISION HISTORY
-- VERSION  DATE         AUTHOR            DESCRIPTION
-- 1.0 	   2014-28-03   Hegbeli Ciprian   Created
-------------------------------------------------------------------------------
-- KEYWORDS : Stream
-------------------------------------------------------------------------------
-- DESCRIPTION : This module implements the Stream protocol for sending the
--				 incoming data to the following module. This version of the module 
--               implements only the receiving of data from the Memory.
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

------------------------------------------------------------------------
-- Module Declaration
------------------------------------------------------------------------
entity stream is
	generic (
		-- Stream data width (must be multiple of 8)
		C_AXI_STREAM_DATA_WIDTH    : integer := 32
	);
	port (
			
		-- Tx FIFO Flags
		TX_FIFO_FULL_I             : in  std_logic;		
		-- Tx FIFO Control signals
		TX_FIFO_D_O                : out std_logic_vector(C_AXI_STREAM_DATA_WIDTH-1 downto 0);
		
		NR_OF_SMPL_I               : in  std_logic_vector(20 downto 0);
		
        RX_STREAM_EN_I             : in std_logic;
		
		-- AXI4-Stream 
		-- Slave
		S_AXIS_MM2S_ACLK_I			: in  std_logic;
		S_AXIS_MM2S_ARESETN			: in  std_logic;
		S_AXIS_MM2S_TREADY_O       : out std_logic;
		S_AXIS_MM2S_TDATA_I        : in  std_logic_vector(C_AXI_STREAM_DATA_WIDTH-1 downto 0);
		S_AXIS_MM2S_TLAST_I        : in  std_logic;
		S_AXIS_MM2S_TVALID_I       : in  std_logic
	
	);
end stream;

architecture Behavioral of stream is

------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------
signal nr_of_rd                 : std_logic_vector (20 downto 0);	
signal tlast                    : std_logic;
signal ready                    : std_logic;

ATTRIBUTE MARK_DEBUG : string;
ATTRIBUTE MARK_DEBUG of nr_of_rd: SIGNAL IS "TRUE";

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
  
begin

------------------------------------------------------------------------ 
-- MM2S protocol implementation
------------------------------------------------------------------------	
	S_Control: process (S_AXIS_MM2S_ACLK_I)
	begin
		if (S_AXIS_MM2S_ACLK_I'event and S_AXIS_MM2S_ACLK_I = '0') then
			if (S_AXIS_MM2S_ARESETN = '0') then
				nr_of_rd <= NR_OF_SMPL_I;
			elsif (RX_STREAM_EN_I = '1') then
				if (nr_of_rd > 0) then
					if (S_AXIS_MM2S_TVALID_I = '1' and ready = '1') then
						TX_FIFO_D_O <= S_AXIS_MM2S_TDATA_I;
						nr_of_rd <= nr_of_rd-1;
					end if;
				end if;
			else
				nr_of_rd <= NR_OF_SMPL_I;
			end if;
		end if;
	end process;
	
	-- ready signal declaration
	ready <= not TX_FIFO_FULL_I when RX_STREAM_EN_I = '1' else
				'0';
	S_AXIS_MM2S_TREADY_O <= ready;
	
end Behavioral;

