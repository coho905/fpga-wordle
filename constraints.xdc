## This file is a general .xdc for the Basys3 rev B board for ENGS31/CoSc56
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

##====================================================================
## External_Clock_Port
##====================================================================
set_property PACKAGE_PIN W5 [get_ports clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]



set_property PACKAGE_PIN B18 [get_ports Rx]  ;# FPGA receives here
set_property IOSTANDARD LVCMOS33                 [get_ports Rx]
set_property PULLUP true                         [get_ports Rx]       ;# keeps line high when idle

set_property PACKAGE_PIN A18 [get_ports Tx]  ;# FPGA drives this out
set_property IOSTANDARD LVCMOS33                     [get_ports Tx]
set_property DRIVE 8                                 [get_ports Tx]
set_property SLEW FAST                               [get_ports Tx]
##====================================================================
## Switch_ports
##====================================================================

##====================================================================
## Implementation Assist
##====================================================================	
## These additional constraints are recommended by Digilent, do not remove!
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]