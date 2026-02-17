create_clock -period 10.000 -waveform {0.000 5.000} [get_ports -filter { NAME =~  "*clk*" && DIRECTION == "IN" }]
set_property PACKAGE_PIN P14 [get_ports clk]
set_property PACKAGE_PIN R12 [get_ports rst_n]
