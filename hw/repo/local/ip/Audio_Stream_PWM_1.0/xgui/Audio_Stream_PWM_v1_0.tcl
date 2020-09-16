# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_AXI_STREAM_DATA_WIDTH" -parent ${Page_0}
  set C_SYS_CLK_FREQ_KHZ [ipgui::add_param $IPINST -name "C_SYS_CLK_FREQ_KHZ" -parent ${Page_0}]
  set_property tooltip {This freaquancy will be used to sample out the data} ${C_SYS_CLK_FREQ_KHZ}
  set C_PDM_FREQ_KHZ [ipgui::add_param $IPINST -name "C_PDM_FREQ_KHZ" -parent ${Page_0}]
  set_property tooltip {The desired sampling out frequancy} ${C_PDM_FREQ_KHZ}


}

proc update_PARAM_VALUE.C_AXI_STREAM_DATA_WIDTH { PARAM_VALUE.C_AXI_STREAM_DATA_WIDTH } {
	# Procedure called to update C_AXI_STREAM_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_STREAM_DATA_WIDTH { PARAM_VALUE.C_AXI_STREAM_DATA_WIDTH } {
	# Procedure called to validate C_AXI_STREAM_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_PDM_FREQ_KHZ { PARAM_VALUE.C_PDM_FREQ_KHZ } {
	# Procedure called to update C_PDM_FREQ_KHZ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PDM_FREQ_KHZ { PARAM_VALUE.C_PDM_FREQ_KHZ } {
	# Procedure called to validate C_PDM_FREQ_KHZ
	return true
}

proc update_PARAM_VALUE.C_SYS_CLK_FREQ_KHZ { PARAM_VALUE.C_SYS_CLK_FREQ_KHZ } {
	# Procedure called to update C_SYS_CLK_FREQ_KHZ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_SYS_CLK_FREQ_KHZ { PARAM_VALUE.C_SYS_CLK_FREQ_KHZ } {
	# Procedure called to validate C_SYS_CLK_FREQ_KHZ
	return true
}

proc update_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to update C_S_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_BASEADDR { PARAM_VALUE.C_S_AXI_BASEADDR } {
	# Procedure called to update C_S_AXI_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_BASEADDR { PARAM_VALUE.C_S_AXI_BASEADDR } {
	# Procedure called to validate C_S_AXI_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S_AXI_HIGHADDR { PARAM_VALUE.C_S_AXI_HIGHADDR } {
	# Procedure called to update C_S_AXI_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_HIGHADDR { PARAM_VALUE.C_S_AXI_HIGHADDR } {
	# Procedure called to validate C_S_AXI_HIGHADDR
	return true
}


proc update_MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_STREAM_DATA_WIDTH { MODELPARAM_VALUE.C_AXI_STREAM_DATA_WIDTH PARAM_VALUE.C_AXI_STREAM_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_STREAM_DATA_WIDTH}] ${MODELPARAM_VALUE.C_AXI_STREAM_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_SYS_CLK_FREQ_KHZ { MODELPARAM_VALUE.C_SYS_CLK_FREQ_KHZ PARAM_VALUE.C_SYS_CLK_FREQ_KHZ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_SYS_CLK_FREQ_KHZ}] ${MODELPARAM_VALUE.C_SYS_CLK_FREQ_KHZ}
}

proc update_MODELPARAM_VALUE.C_PDM_FREQ_KHZ { MODELPARAM_VALUE.C_PDM_FREQ_KHZ PARAM_VALUE.C_PDM_FREQ_KHZ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_PDM_FREQ_KHZ}] ${MODELPARAM_VALUE.C_PDM_FREQ_KHZ}
}

