# =====================================================================
# Lab 11 - FPGA constraints for the Digilent Nexys A7 / Nexys 4 DDR
# (Artix-7 XC7A100T-CSG324). The board has exactly eight common-anode
# seven-segment displays, matching the seven_seg_display driver.
#
# Top module: lab11_top
#   clk    -> 100 MHz board oscillator
#   reset  -> centre push button (BTNC, active high)
#   an0..7 -> digit anodes  (active low)
#   segA..G-> segments CA..CG (active low)
# =====================================================================

## 100 MHz system clock
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -name sys_clk -period 10.000 -waveform {0 5} [get_ports clk]

## Reset - centre push button (BTNC)
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports reset]

## Seven-segment cathodes (segments a..g), active low
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports segA]
set_property -dict {PACKAGE_PIN R10 IOSTANDARD LVCMOS33} [get_ports segB]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports segC]
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports segD]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports segE]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports segF]
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports segG]

## Seven-segment anodes (digit enables), active low
set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports an0]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports an1]
set_property -dict {PACKAGE_PIN T9  IOSTANDARD LVCMOS33} [get_ports an2]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports an3]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports an4]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports an5]
set_property -dict {PACKAGE_PIN K2  IOSTANDARD LVCMOS33} [get_ports an6]
set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports an7]
