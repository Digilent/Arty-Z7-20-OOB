library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hdmi_loopback_logic_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S_AXI
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
      -- Users to add ports here
      oVde : out std_logic;
      oHsync : out std_logic;
      oVsync : out std_logic;
      oData : out std_logic_vector(23 downto 0);
      oRst : out std_logic;
      OutPixelClk : in std_logic;
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
      
      -- User ports ends
      -- Do not modify the ports beyond this line
      
      
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
end hdmi_loopback_logic_v1_0;

architecture arch_imp of hdmi_loopback_logic_v1_0 is

	-- component declaration
	component hdmi_loopback_logic_v1_0_S_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
		xTestRst : out std_logic;
      xDone : in std_logic;
      xError : in std_logic;
      xStatus : in std_logic_vector(3 downto 0);
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
	end component hdmi_loopback_logic_v1_0_S_AXI;

signal xError, xError_reg, xTestRst, xDone, xDone_reg, oDone, oError, oRdy, oValid : std_logic;
signal oStatus, xStatus, xStatus_reg : std_logic_vector(3 downto 0);
begin

-- Instantiation of Axi Bus Interface S_AXI
hdmi_loopback_logic_v1_0_S_AXI_inst : hdmi_loopback_logic_v1_0_S_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S_AXI_ADDR_WIDTH
	)
	port map (
	   xTestRst => xTestRst,
      xDone => xDone_reg,
      xError => xError_reg,
      xStatus => xStatus_reg,
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

	-- Add user logic here
TestLogic: entity work.txrx_compare
   Port map (
      oVde => oVde,
      oHsync => oHsync,
      oVsync => oVsync,
      oData => oData,
      OutPixelClk => OutPixelClk,
      oRst => oRst,    
      aCECo_I => aCECo_I,
      aCECo_O => aCECo_O,
      aCECo_T => aCECo_T,
      aHPA => aHPA,
      
      iVde => iVde,
      iHsync => iHsync,
      iVsync => iVsync,
      iData => iData,
      InPixelClk => InPixelClk,
      aPixelClkLckd => aPixelClkLckd,
      aCECi => aCECi,
      aHPD => aHPD,
      
      oDone => oDone,
      oError => oError,
      oStatus => oStatus,  
      aRst => xTestRst
   );

HandshakeDataStatus: entity work.HandshakeData
   Generic map (
      kDataWidth => 4)
   Port Map (
      InClk => OutPixelClk,
      OutClk => s_axi_aclk,
      iData => oStatus,
      oData => xStatus,
      iPush => oRdy,
      iRdy => oRdy,
      oAck => '1',
      oValid => oValid,
      aReset => not s_axi_aresetn);

process(s_axi_aclk)
begin
   if Rising_Edge(s_axi_aclk) then
      if (s_axi_aresetn = '0') then
         xStatus_reg <= (others => '0');
         xDone_reg <= '0';
         xError_reg <= '0';
      elsif (oValid = '1') then
         xStatus_reg <= xStatus;
         xDone_reg <= xDone;
         xError_reg <= xError;
      end if; 
   end if;
end process;

SyncBaseDone: entity work.SyncBase
   Generic map (
      kResetTo => '0' --value when reset and upon init
   )
   Port map (
      aReset => not s_axi_aresetn, -- active-high asynchronous reset
      InClk => OutPixelClk,
      iIn => oDone,
      OutClk => s_axi_aclk,
      oOut => xDone);
SyncBaseError: entity work.SyncBase
   Generic map (
      kResetTo => '0' --value when reset and upon init
   )
   Port map (
      aReset => not s_axi_aresetn, -- active-high asynchronous reset
      InClk => OutPixelClk,
      iIn => oError,
      OutClk => s_axi_aclk,
      oOut => xError);       
	-- User logic ends

end arch_imp;
