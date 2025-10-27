create_clock -name clk -period 20.0 [get_ports {CLOCK_50}]

set_false_path -from * -to [get_ports LEDR[*]]
#set_false_path -from * -to [get_ports LEDG[*]]
#set_false_path -from * -to [get_ports HEX0[*]]
#set_false_path -from * -to [get_ports HEX1[*]]
#set_false_path -from * -to [get_ports HEX2[*]]
#set_false_path -from * -to [get_ports HEX3[*]]
set_false_path -from [get_ports KEY[*]] -to *
#set_false_path -from [get_ports SW[*]] -to *

#set_false_path -from reset -to *