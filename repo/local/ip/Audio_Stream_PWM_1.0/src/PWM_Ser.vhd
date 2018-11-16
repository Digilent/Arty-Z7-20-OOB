------------------------------------------------------------------------------
--
-- File: PWM_Ser.vhd
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
-- Receives Samples and turns them in to PWM signals. The received samples
-- will be on 16 bit and they are considered signed. The sampling rate is 
-- calculated from incoming clock (whose value must be specified in the  
-- C_SYS_CLK_FREQ_KHZ parameter) and the desired sampling frequency 
-- (value provided trough C_PDM_FREQ_KHZ)
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_signed.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

------------------------------------------------------------------------
-- Module Declaration
------------------------------------------------------------------------
entity PWM_Ser is
    generic(
           C_SYS_CLK_FREQ_KHZ : integer := 100000;
           C_PDM_FREQ_KHZ : integer range 1 to 192 := 48           
            );
    Port ( CLK : in STD_LOGIC;
           EN_I : in STD_LOGIC;
           EMPTY_I : in STD_LOGIC;
           DATA_I : in integer;
           LD_O : out STD_LOGIC;
           AUD_PWM_O : out STD_LOGIC;
           AUD_SD_O : out STD_LOGIC);
end PWM_Ser;

architecture Behavioral of PWM_Ser is 
------------------------------------------------------------------------
-- Constant Declarations
------------------------------------------------------------------------   
constant MAX_SAMPLE_VALUE:      integer := 32767; -- max sample value (signed 16 bit)
constant MIN_SAMPLE_VALUE:      integer := -32767; -- min sample value (signed 16 bit)
-- bit increment is calculated using below formula, for the default value the increment value is
-- ((32767+32767)*48)/100000 = 31
constant CNT_BIT_INC:           integer := ((MAX_SAMPLE_VALUE - MIN_SAMPLE_VALUE)*C_PDM_FREQ_KHZ)/C_SYS_CLK_FREQ_KHZ;
 
------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------   
signal cnt_bits:                integer := MIN_SAMPLE_VALUE;
signal data_int:                integer := 0;

begin

------------------------------------------------------------------------ 
-- Data loading and PWM counter process
------------------------------------------------------------------------
CNT_BIT_PROC: process(CLK)
begin
    if rising_edge(CLK) then
        if EN_I = '1' then 
            if (cnt_bits >= MAX_SAMPLE_VALUE and EMPTY_I = '0') then
                cnt_bits <= MIN_SAMPLE_VALUE;
                LD_O <= '1';
                data_int <= DATA_I;
            else
                cnt_bits <= cnt_bits + CNT_BIT_INC; 
                LD_O <= '0';
            end if;
        else 
            data_int <= MIN_SAMPLE_VALUE;
            cnt_bits <= MIN_SAMPLE_VALUE;
            LD_O <= '0';
        end if;
    end if;
end process CNT_BIT_PROC;

------------------------------------------------------------------------ 
-- Audio PWM Generation process
------------------------------------------------------------------------
SHIFT_OUT: process(CLK)
begin
    if rising_edge(CLK) then
        if  cnt_bits < data_int then
            AUD_PWM_O <= '1';
        else
            AUD_PWM_O <= '0';
        end if;
    end if;
end process SHIFT_OUT;

AUD_SD_O <= '1';

end Behavioral;
