------------------------------------------------------------------------------
--
-- File: Audio_Stream_PWM_v1_0.vhd
-- Author: Hegbeli Ciprian
-- Original Project: Audio_stream_PWM 
-- Date: 20 December 2016
--
-------------------------------------------------------------------------------
-- (c) 2016 Copyright Digilent Incorporated
-- All Rights Reserved
-- 
-- This program is free software; distributed under the terms of BSD 3-clause 
-- license ("Revised BSD License", "New BSD License", or "Modified BSD License")
--
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice, this
--    list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
-- 3. Neither the name(s) of the above-listed copyright holder(s) nor the names
--    of its contributors may be used to endorse or promote products derived
--    from this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
-- FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
-- SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
-- CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
-- OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
-- OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-------------------------------------------------------------------------------
--
-- Purpose:
-- This is the top module of the Project, it combine the AXI-Lite and Axi-Stream
-- to the PWM generator and the FIFO, which handles de acquired samples.
-- Here, control to the PWM and AXI-Stream interface is provided trough the 
-- AXI-Lite register space; the  control signals are mapped to the registers.
-- The handling of the register space and the AXI-Lite interface signals have
-- been generated automatically by the Xilinx IP core generator 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

------------------------------------------------------------------------
-- Module Declaration
------------------------------------------------------------------------
entity Audio_Stream_PWM_v1_0 is
	generic (
		-- Users to add parameters here

        C_AXI_STREAM_DATA_WIDTH    : integer := 32;
        C_SYS_CLK_FREQ_KHZ         : integer := 100000;
        C_PDM_FREQ_KHZ             : integer range 1 to 192 := 48;
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S_AXI
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (             
         -- AXI4-Stream
         S_AXIS_MM2S_ACLK               : in  std_logic;
         S_AXIS_MM2S_ARESETN            : in  std_logic;
         S_AXIS_MM2S_TREADY             : out std_logic;
         S_AXIS_MM2S_TDATA              : in  std_logic_vector(C_AXI_STREAM_DATA_WIDTH-1 downto 0);
         S_AXIS_MM2S_TKEEP              : in  std_logic_vector((C_AXI_STREAM_DATA_WIDTH/8)-1 downto 0);
         S_AXIS_MM2S_TLAST              : in  std_logic;
         S_AXIS_MM2S_TVALID             : in  std_logic;
         
         --PWM
         AUD_PWM                        : out STD_LOGIC;
         AUD_SD                         : out STD_LOGIC;

		-- Ports of Axi Slave Bus Interface S_AXI
		s_axi_aclk	: in std_logic;
		s_axi_aresetn	: in std_logic;
		s_axi_awaddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_awprot	: in std_logic_vector(2 downto 0);
		s_axi_awvalid	: in std_logic;
		s_axi_awready	: out std_logic;
		s_axi_wdata	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		s_axi_wstrb	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		s_axi_wvalid	: in std_logic;
		s_axi_wready	: out std_logic;
		s_axi_bresp	: out std_logic_vector(1 downto 0);
		s_axi_bvalid	: out std_logic;
		s_axi_bready	: in std_logic;
		s_axi_araddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_arprot	: in std_logic_vector(2 downto 0);
		s_axi_arvalid	: in std_logic;
		s_axi_arready	: out std_logic;
		s_axi_rdata	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		s_axi_rresp	: out std_logic_vector(1 downto 0);
		s_axi_rvalid	: out std_logic;
		s_axi_rready	: in std_logic
	);
end Audio_Stream_PWM_v1_0;

architecture arch_imp of Audio_Stream_PWM_v1_0 is
------------------------------------------------------------------------
-- Component Declarations
------------------------------------------------------------------------

    -- Automatically generated AXI-Lite module
	component Audio_Stream_PWM_v1_0_S_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
		--Global reset
        SOFT_RESETN     : out std_logic;
        --Global Enable
        EN              : out std_logic;
        --The desired number of samples for the AXI-Stream interface
        NR_OF_SAMPLES   : out std_logic_vector(20 downto 0);
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component Audio_Stream_PWM_v1_0_S_AXI;
	 
    -- the stream module which controls the receiving and transmitting of data
    -- on the AXI stream	
	component stream is
        generic (
            C_AXI_STREAM_DATA_WIDTH    : integer := 32
        );
        port (
            TX_FIFO_FULL_I             : in  std_logic;
            TX_FIFO_D_O                : out std_logic_vector(C_AXI_STREAM_DATA_WIDTH-1 downto 0);            
            NR_OF_SMPL_I               : in  std_logic_vector(20 downto 0);            
            RX_STREAM_EN_I             : in std_logic;
            S_AXIS_MM2S_ACLK_I         : in  std_logic;
            S_AXIS_MM2S_ARESETN        : in  std_logic;
            S_AXIS_MM2S_TREADY_O       : out std_logic;
            S_AXIS_MM2S_TDATA_I        : in  std_logic_vector(C_AXI_STREAM_DATA_WIDTH-1 downto 0);
            S_AXIS_MM2S_TLAST_I        : in  std_logic;
            S_AXIS_MM2S_TVALID_I       : in  std_logic        
        );	
	end component stream;
	
	-- Sample to PWM serialiser
	component PWM_Ser is
	   generic (
           C_SYS_CLK_FREQ_KHZ          : integer := 100000;
           C_PDM_FREQ_KHZ              : integer range 1 to 192 := 48
	   );
	   port (
	       CLK                         : in STD_LOGIC;
           EN_I                        : in STD_LOGIC;
           EMPTY_I                     : in STD_LOGIC;
           DATA_I                      : in integer;
           LD_O                        : out STD_LOGIC;
           AUD_PWM_O                   : out STD_LOGIC;
           AUD_SD_O                    : out STD_LOGIC
	   );
	end component PWM_Ser;
	
	--Fifo generator 
	COMPONENT fifo_16
      PORT (
        clk : IN STD_LOGIC;
        srst : IN STD_LOGIC;
        din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        wr_en : IN STD_LOGIC;
        rd_en : IN STD_LOGIC;
        dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        full : OUT STD_LOGIC;
        empty : OUT STD_LOGIC
      );
    END COMPONENT;
 
------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------       
signal soft_resetn      : std_logic;
signal en               : std_logic;
signal nr_of_samples    : std_logic_vector(20 downto 0);
signal data_i           : integer;
signal full_fifo        : std_logic;
signal empty_fifo       : std_logic;
signal din_fifo         : std_logic_vector(31 downto 0);
signal dout_fifo        : std_logic_vector(31 downto 0);
signal load             : std_logic;
signal valid            : std_logic;

begin
------------------------------------------------------------------------ 
-- Signals assignments
------------------------------------------------------------------------

--Data and and valid assignment and link to EN signal
data_i <= to_integer(signed(dout_fifo(15 downto 0))) when en = '1' else -32767;
valid <= not full_fifo when (en = '1' and S_AXIS_MM2S_TVALID = '1') else '0';

------------------------------------------------------------------------
-- Instantiaton of Modules
------------------------------------------------------------------------

-- Instantiation of Axi Bus Interface S_AXI
Audio_Stream_PWM_v1_0_S_AXI_inst : Audio_Stream_PWM_v1_0_S_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S_AXI_ADDR_WIDTH
	)
	port map (
	    SOFT_RESETN => soft_resetn,
	    EN          => en,
	    NR_OF_SAMPLES   => nr_of_samples,
		S_AXI_ACLK	=> s_axi_aclk,
		S_AXI_ARESETN	=> s_axi_aresetn,
		S_AXI_AWADDR	=> s_axi_awaddr,
		S_AXI_AWPROT	=> s_axi_awprot,
		S_AXI_AWVALID	=> s_axi_awvalid,
		S_AXI_AWREADY	=> s_axi_awready,
		S_AXI_WDATA	=> s_axi_wdata,
		S_AXI_WSTRB	=> s_axi_wstrb,
		S_AXI_WVALID	=> s_axi_wvalid,
		S_AXI_WREADY	=> s_axi_wready,
		S_AXI_BRESP	=> s_axi_bresp,
		S_AXI_BVALID	=> s_axi_bvalid,
		S_AXI_BREADY	=> s_axi_bready,
		S_AXI_ARADDR	=> s_axi_araddr,
		S_AXI_ARPROT	=> s_axi_arprot,
		S_AXI_ARVALID	=> s_axi_arvalid,
		S_AXI_ARREADY	=> s_axi_arready,
		S_AXI_RDATA	=> s_axi_rdata,
		S_AXI_RRESP	=> s_axi_rresp,
		S_AXI_RVALID	=> s_axi_rvalid,
		S_AXI_RREADY	=> s_axi_rready
	);

-- Instantiation of AXI-Stream interface
Inst_Stream: stream
    generic map (
        C_AXI_STREAM_DATA_WIDTH     => C_AXI_STREAM_DATA_WIDTH
    )
    port map (        
        TX_FIFO_FULL_I              => full_fifo,
        TX_FIFO_D_O                 => din_fifo,
        NR_OF_SMPL_I                => nr_of_samples,
        RX_STREAM_EN_I              => en,
        S_AXIS_MM2S_ACLK_I          => S_AXIS_MM2S_ACLK,
        S_AXIS_MM2S_ARESETN         => S_AXIS_MM2S_ARESETN,
        S_AXIS_MM2S_TREADY_O        => S_AXIS_MM2S_TREADY,
        S_AXIS_MM2S_TDATA_I         => S_AXIS_MM2S_TDATA,
        S_AXIS_MM2S_TLAST_I         => S_AXIS_MM2S_TLAST,
        S_AXIS_MM2S_TVALID_I        => S_AXIS_MM2S_TVALID
    );
    
-- Instantiation of PWM serialiser
Inst_PWM: PWM_Ser
    generic map(
        C_SYS_CLK_FREQ_KHZ          => C_SYS_CLK_FREQ_KHZ,
        C_PDM_FREQ_KHZ              => C_PDM_FREQ_KHZ        
    )
    port map(
        CLK                         => S_AXIS_MM2S_ACLK,
        EN_I                        => en,
        EMPTY_I                     => empty_fifo,
        DATA_I                      => data_i,
        LD_O                        => load,
        AUD_PWM_O                   => AUD_PWM,
        AUD_SD_O                    => AUD_SD
    );
    
-- Instantiation of 16 bit FIFO       
Inst_FIFO_16: fifo_16
    port map(
        clk                         => S_AXIS_MM2S_ACLK,
        srst                        => not (SOFT_RESETN),
        din                         => din_fifo,
        wr_en                       => valid,
        rd_en                       => load,
        dout                        => dout_fifo,
        full                        => full_fifo,
        empty                       => empty_fifo
    ); 

end arch_imp;
