----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/24/2015 12:34:17 PM
-- Design Name: 
-- Module Name: txrx_compare - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity txrx_compare is
   Port (
      oVde : out std_logic;
      oHsync : out std_logic;
      oVsync : out std_logic;
      oData : out std_logic_vector(23 downto 0);
      OutPixelClk : in std_logic;
      oRst : out std_logic;
      aCECo_I : in std_logic; -- unused
      aCECo_O : out std_logic;
      aCECo_T : out std_logic;
      aHPA : out std_logic;
      
      iVde : in std_logic;
      iHsync : in std_logic;
      iVsync : in std_logic;
      iData : in std_logic_vector(23 downto 0);
      InPixelClk : in std_logic;
      aPixelClkLckd : in std_logic;
      aCECi : in std_logic;
      aHPD : in std_logic;
      
      oDone : out std_logic;
      oError : out std_logic;
      oStatus : out std_logic_vector(3 downto 0);
      aRst : in std_logic
      
   );
end txrx_compare;

architecture Behavioral of txrx_compare is

type state_type is (stReset, stClockLock, stActiveVideo, stError, stDone, stTestCEC0, stTestCEC1, stTestHPA0, stTestHPA1); 
signal state, nstate : state_type; 

attribute enum_encoding : string;
attribute enum_encoding of state_type : type is "0000 0001 0010 0011 0100 0101 0110 0111 1000";

--other outputs
signal oRst_in, oRst_int, oPixelClkLckd : std_logic;

constant testData : std_logic_vector(23 downto 0) := x"DEADBE";
constant testHsync : std_logic := '1';
constant testVsync : std_logic := '0';

constant kTout : natural := 5 * 100_000_000; --5s
signal toutCnt : natural range 0 to kTout := kTout;
signal oTimeout : std_logic;
signal oDummyVde : unsigned(8 downto 0) := (others => '0'); -- if MSB is VDE, blanking will be 256 pixel wide > 128
signal oCECin, oHPDin, oVdeIn, oCECTest, oHPATest : std_logic;

constant kLineDelay : natural := 25000; -- 250us rise time for CEC
signal lineDelay : natural range 0 to kLineDelay;

begin

-- CEC is open-drain 
aCECo_O <= '0';
aCECo_T <= oCECTest; -- '0'=drive; '1'=tristate

aHPA <= not oHPATest; -- G2 has HPD inverted;

-- Bring aCECi into the FSM domain
SyncAsyncCEC: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 2) --use double FF synchronizer
   port map (
      aReset => oRst_int, -- active-high asynchronous reset
      aIn => aCECi,
      OutClk => OutPixelClk,
      oOut => oCECin);

-- Bring aHPD into the FSM domain
SyncAsyncHPD: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 2) --use double FF synchronizer
   port map (
      aReset => oRst_int, -- active-high asynchronous reset
      aIn => aHPD,
      OutClk => OutPixelClk,
      oOut => oHPDin); 
      
-- Bring aRst into the FSM clock domain
SyncAsyncReset: entity work.ResetBridge
   Generic map (
      kPolarity => '1')
   Port map (
      aRst => aRst,
      OutClk => OutPixelClk,
      oRst => oRst_in);

-- Bring aPixelClkLckd into the FSM domain
SyncAsyncx: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 2) --use double FF synchronizer
   port map (
      aReset => oRst_int, -- active-high asynchronous reset
      aIn => aPixelClkLckd,
      OutClk => OutPixelClk,
      oOut => oPixelClkLckd); 

SyncVDE: entity work.SyncBase
   Generic map (
      kResetTo => '0' --value when reset and upon init
   )
   Port map (
      aReset => oRst_int, -- active-high asynchronous reset
      InClk => InPixelClk,
      iIn => iVde,
      OutClk => OutPixelClk,
      oOut => oVdeIn);
      

--TimeoutCounter: process (OutPixelClk)
--begin
--   if Rising_Edge(OutPixelClk) then
--      if (oRst_int = '1') then
--         toutCnt <= kTout;
--      elsif toutCnt /= 0 then
--         toutCnt <= toutCnt - 1;
--      end if;
--   end if;
--end process TimeoutCounter;
--oTimeout <= '1' when toutCnt = 0 else '0';

LineDelayCounter: process (OutPixelClk)
begin
   if Rising_Edge(OutPixelClk) then
--      if (state /= nstate) then
--         lineDelay <= kLineDelay;
--      elsif lineDelay /= 0 then
         lineDelay <= lineDelay - 1;
--      end if;
   end if;
end process LineDelayCounter;

GenerateBlanking: process(OutPixelClk)
begin
   if Rising_Edge(OutPixelClk) then
      oDummyVde <= oDummyVde + 1;
   end if;
end process GenerateBlanking;

--Insert the following in the architecture after the begin keyword
SYNC_PROC: process (OutPixelClk)
begin
   if (OutPixelClk'event and OutPixelClk = '1') then
      if (oRst_in = '1') then
         state <= stReset;
         oStatus <= std_logic_vector(to_unsigned(state_type'pos(stReset), oStatus'length));
      else
         state <= nstate;
         if (nstate /= stError) then --if error, keep the last state we were in for debug purposes
            oStatus <= std_logic_vector(to_unsigned(state_type'pos(nstate), oStatus'length));
         end if;
      end if;
   end if;
end process;

OUTPUT_DECODE: process(state)
begin
   if (state = stReset) then
      oRst_int <= '1';
   else
      oRst_int <= '0';
   end if;
   
   if (state = stTestHPA1) then
      oHPATest <= '1';
   else
      oHPATest <= '0';
   end if;
   if (state = stTestCEC1) then
      oCECTest <= '1';
   else
      oCECTest <= '0';
   end if;
   if (state = stDone or state = stError) then
      oDone <= '1';
   else
      oDone <= '0';
   end if;
   if (state = stError) then
      oError <= '1';
   else
      oError <= '0';      
   end if;     
end process;

oRst <= oRst_int;
oVde <= oDummyVde(oDummyVde'high); --this is needed for phase alignment
 
oData <= testData;
oHsync <= testHsync;
oVsync <= testVsync;
         
NEXT_STATE_DECODE: process (state, oPixelClkLckd, lineDelay, oCECin, oCECTest, oHPDin, oHPATest, oVdeIn)
begin
   --declare default state for nstate to avoid latches
   nstate <= state;  --default is to stay in current state

   case (state) is
      when stReset =>
         nstate <= stClockLock;
      when stClockLock => --input clock detected
         if (oPixelClkLckd = '1') then
            nstate <= stActiveVideo;
         end if;
      when stActiveVideo => --input reached phase alignment
         if (oVdeIn = '1') then
            nstate <= stTestCEC0;       
         end if;
      when stTestCEC0 =>
         if (lineDelay = 0) then
            if (oCECin = '0') then
               nstate <= stTestCEC1;
            else
               nstate <= stError;
            end if;
         end if;
      when stTestCEC1 =>
         if (lineDelay = 0) then
            if (oCECin = '1') then
               nstate <= stTestHPA0;
            else
               nstate <= stError;
            end if;
         end if;
      when stTestHPA0 =>
         if (lineDelay = 0) then
            if (oHPDin = oHPATest) then
               nstate <= stTestHPA1;
            else
               nstate <= stError;
            end if;
         end if;
      when stTestHPA1 =>
         if (lineDelay = 0) then
            if (oHPDin = oHPATest) then
               nstate <= stDone;
            else
               nstate <= stError;
            end if;
         end if;                  
      when stError => --stay
      when stDone => --stay
--      when others =>
--         nstate <= stReset;
   end case;      
end process;



end Behavioral;
