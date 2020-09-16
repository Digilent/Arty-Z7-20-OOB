library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rgb_led_v1_0 is
	generic (
		-- Users to add parameters here

        led_width: integer range 1 to 8  := 1;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 5
	);
	port (
		-- Users to add ports here
        rgb0: out std_logic_vector(2 downto 0);
        rgb1: out std_logic_vector(2 downto 0);
        rgb2: out std_logic_vector(2 downto 0);
        rgb3: out std_logic_vector(2 downto 0);
        rgb4: out std_logic_vector(2 downto 0);
        rgb5: out std_logic_vector(2 downto 0);
        rgb6: out std_logic_vector(2 downto 0);
        rgb7: out std_logic_vector(2 downto 0);
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end rgb_led_v1_0;

architecture arch_imp of rgb_led_v1_0 is

	-- component declaration
	component rgb_led_v1_0_S00_AXI is
		generic (
            led_w: integer := 1;
            C_S_AXI_DATA_WIDTH	: integer	:= 32;
            C_S_AXI_ADDR_WIDTH	: integer	:= 5
		);
		port (
            rgb : out STD_LOGIC_VECTOR (3 * led_w - 1 downto 0);
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
	end component rgb_led_v1_0_S00_AXI;

    signal rgb : STD_LOGIC_VECTOR (3 * led_width - 1 downto 0) := (others => '0');

begin

-- Instantiation of Axi Bus Interface S00_AXI
rgb_led_v1_0_S00_AXI_inst : rgb_led_v1_0_S00_AXI
	generic map (
        led_w => led_width,
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
        rgb => rgb,
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

	-- Add user logic here
DataGen: for i in 0 to led_width-1 generate
	-- User logic ends
    Data0: if i = 0 generate
        rgb0 <= rgb(2 downto 0);
    end generate;
    
    Data1: if i = 1 generate
        rgb1 <= rgb(5 downto 3);
    end generate;
    
    Data2: if i = 2 generate
        rgb2 <= rgb(8 downto 6);
    end generate;
    
    Data3: if i = 3 generate
        rgb3 <= rgb(11 downto 9);
    end generate;
            
    Data4: if i = 4 generate
        rgb4 <= rgb(14 downto 12);
    end generate;
            
    Data5: if i = 5 generate
        rgb5 <= rgb(17 downto 15);
    end generate;
            
    Data6: if i = 6 generate
        rgb6 <= rgb(20 downto 18);
    end generate;
            
    Data7: if i = 7 generate
        rgb7 <= rgb(23 downto 21);
    end generate;
    
end generate DataGen;

end arch_imp;
