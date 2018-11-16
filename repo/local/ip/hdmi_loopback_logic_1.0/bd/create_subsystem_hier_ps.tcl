startgroup
set hier_name hdmi_loopback_test
create_bd_cell -type hier $hier_name
create_bd_cell -type ip -vlnv digilentinc.com:ip:hdmi_loopback_logic:1.0 $hier_name/hdmi_loopback_logic_0
create_bd_cell -type ip -vlnv digilentinc.com:ip:dvi2rgb:1.6 $hier_name/dvi2rgb_0
create_bd_cell -type ip -vlnv digilentinc.com:ip:rgb2dvi:1.3 $hier_name/rgb2dvi_0
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic:2.0 $hier_name/axi_iic_0
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 $hier_name/axi_timer_0
set_property -dict [list CONFIG.kClkRange {2}] [get_bd_cells $hier_name/dvi2rgb_0]
set_property -dict [list CONFIG.kClkRange {2}] [get_bd_cells $hier_name/rgb2dvi_0]
set_property -dict [list CONFIG.enable_timer2 {0}] [get_bd_cells $hier_name/axi_timer_0]
set_property -dict [list CONFIG.C_SCL_INERTIAL_DELAY {5} CONFIG.C_SDA_INERTIAL_DELAY {5}] [get_bd_cells $hier_name/axi_iic_0]
connect_bd_intf_net [get_bd_intf_pins $hier_name/dvi2rgb_0/RGB] [get_bd_intf_pins $hier_name/hdmi_loopback_logic_0/vid_i]
connect_bd_intf_net [get_bd_intf_pins $hier_name/hdmi_loopback_logic_0/vid_o] [get_bd_intf_pins $hier_name/rgb2dvi_0/RGB]
connect_bd_net [get_bd_pins $hier_name/rgb2dvi_0/aRst] [get_bd_pins $hier_name/hdmi_loopback_logic_0/oRst]
connect_bd_net -net [get_bd_nets $hier_name/hdmi_loopback_logic_0_oRst] [get_bd_pins $hier_name/dvi2rgb_0/aRst] [get_bd_pins $hier_name/hdmi_loopback_logic_0/oRst]
connect_bd_net [get_bd_pins $hier_name/dvi2rgb_0/aPixelClkLckd] [get_bd_pins $hier_name/hdmi_loopback_logic_0/aPixelClkLckd]
connect_bd_net [get_bd_pins $hier_name/dvi2rgb_0/PixelClk] [get_bd_pins $hier_name/hdmi_loopback_logic_0/InPixelClk]
create_bd_intf_pin -mode Slave -vlnv digilentinc.com:interface:tmds_rtl:1.0 $hier_name/hdmi_rx
connect_bd_intf_net [get_bd_intf_pins $hier_name/hdmi_rx] [get_bd_intf_pins $hier_name/dvi2rgb_0/TMDS]
create_bd_intf_pin -mode Master -vlnv digilentinc.com:interface:tmds_rtl:1.0 $hier_name/hdmi_tx
connect_bd_intf_net [get_bd_intf_pins $hier_name/hdmi_tx] [get_bd_intf_pins $hier_name/rgb2dvi_0/TMDS]
create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 $hier_name/ddc_tx
connect_bd_intf_net [get_bd_intf_pins $hier_name/ddc_tx] [get_bd_intf_pins $hier_name/axi_iic_0/IIC]
create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 $hier_name/ddc_rx
connect_bd_intf_net [get_bd_intf_pins $hier_name/ddc_rx] [get_bd_intf_pins $hier_name/dvi2rgb_0/DDC]
create_bd_pin -dir I $hier_name/PixelClk
connect_bd_net [get_bd_pins $hier_name/PixelClk] [get_bd_pins $hier_name/rgb2dvi_0/PixelClk]
connect_bd_net -net [get_bd_nets $hier_name/PixelClk_1] [get_bd_pins $hier_name/PixelClk] [get_bd_pins $hier_name/hdmi_loopback_logic_0/OutPixelClk]
create_bd_pin -dir I $hier_name/RefClk
connect_bd_net [get_bd_pins $hier_name/RefClk] [get_bd_pins $hier_name/dvi2rgb_0/RefClk]
create_bd_pin -dir I $hier_name/cec_rx
connect_bd_net [get_bd_pins $hier_name/cec_rx] [get_bd_pins $hier_name/hdmi_loopback_logic_0/aCECi]
create_bd_pin -dir I $hier_name/hpd_tx
connect_bd_net [get_bd_pins $hier_name/hpd_tx] [get_bd_pins $hier_name/hdmi_loopback_logic_0/aHPD]
create_bd_pin -dir O $hier_name/hpa_rx
connect_bd_net [get_bd_pins $hier_name/hpa_rx] [get_bd_pins $hier_name/hdmi_loopback_logic_0/aHPA]
create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 $hier_name/cec_tx
connect_bd_intf_net [get_bd_intf_pins $hier_name/cec_tx] [get_bd_intf_pins $hier_name/hdmi_loopback_logic_0/aCECo]
create_bd_pin -dir O $hier_name/iic2intc_irpt
connect_bd_net [get_bd_pins $hier_name/iic2intc_irpt] [get_bd_pins $hier_name/axi_iic_0/iic2intc_irpt]
endgroup

startgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins hdmi_loopback_test/hdmi_loopback_logic_0/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins hdmi_loopback_test/axi_iic_0/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins hdmi_loopback_test/axi_timer_0/S_AXI]
endgroup
