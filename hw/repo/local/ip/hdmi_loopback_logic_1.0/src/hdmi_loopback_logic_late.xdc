### Asynchronous clock domain crossings ###
set_false_path -through [get_pins -filter {NAME =~ */SyncAsync*/oSyncStages*/PRE || NAME =~ */SyncAsync*/oSyncStages*/CLR} -hier]
set_false_path -through [get_pins -filter {NAME =~ *SyncAsync*/oSyncStages_reg[0]/D} -hier]
set_false_path -through [get_pins -filter {NAME =~ *SyncBase*/iIn_q*/PRE || NAME =~ *SyncBase*/iIn_q*/CLR} -hier]

# The handshake module does not need recovery check on aReset
set_false_path -through [get_pins HandshakeData*/*/CLR]

# We handshake status data form the PixelClk domain to the AXI clock domain
# Make sure the path from the iData_int register to oData register is smaller than 2 OutClk (s_axi_aclk) periods
# This constraint file should be set for late processing so that top-level and other IP constraints have a chance
# to create clocks
set OutClk [get_clocks -of [get_ports s_axi_aclk]]
set_max_delay -datapath_only -from [get_pins HandshakeData*/iData_int_reg[*]/C] -to [get_pins HandshakeData*/oData_reg[*]/D] [expr [get_property -min PERIOD $OutClk] * 2]