set_property IOSTANDARD LVCMOS33 [get_ports sysclk]
set_property IOSTANDARD LVCMOS33 [get_ports mosi]
set_property IOSTANDARD LVCMOS33 [get_ports miso]
set_property IOSTANDARD LVCMOS33 [get_ports sck]
set_property IOSTANDARD LVCMOS33 [get_ports cs]
set_property IOSTANDARD LVCMOS33 [get_ports start]
# set_property IOSTANDARD LVCMOS33 [get_ports tx_we]
# set_property IOSTANDARD LVCMOS33 [get_ports ready]
# set_property IOSTANDARD LVCMOS33 [get_ports mosi_dbg]
# set_property IOSTANDARD LVCMOS33 [get_ports miso_dbg]
# set_property IOSTANDARD LVCMOS33 [get_ports sck_dbg]
# set_property IOSTANDARD LVCMOS33 [get_ports cs_dbg]

# FPGA_QSPI_D P2    (MOSI)
# FPGA_QSPI_CLK H14 (SCK)
# FPGA_QSPI_Q L14   (MISO)
# FPGA_QSPI_CS M13  (CS)
# FPGA_QSPI_WP J13
# FPGA_QSPI_HD D13

# FPGA_IO10 C3 (user button aka BUTTON1)
# FPGA_IO11 M4 (user button aka BUTTON2)
# FPGA_LED1 J1

# I2C
# SDO J14
# SDA P13
# SCL P12

# USER BUTTONS:
set_property PACKAGE_PIN C3 [get_ports start]
# set_property PACKAGE_PIN M4 [get_ports tx_we]
# ------------

# USER LEDs:
set_property PACKAGE_PIN J1 [get_ports ready]
# ------------

# SPI/QSPI:
set_property PACKAGE_PIN P2 [get_ports mosi]
set_property PACKAGE_PIN L14 [get_ports miso]
set_property PACKAGE_PIN H14 [get_ports sck]
set_property PACKAGE_PIN M13 [get_ports cs]
# set_property PACAKGE_PIN J13 [get_ports wp]
# set_property PACAKGE_PIN D13 [get_ports hd]
# ------------

# IO0
# set_property PACKAGE_PIN N14 [get_ports sck_dbg]
# # IO1
# set_property PACKAGE_PIN M14 [get_ports mosi_dbg]
# # IO2
# set_property PACKAGE_PIN C4  [get_ports miso_dbg]
# # IO3
# set_property PACKAGE_PIN B13 [get_ports cs_dbg]

# SYSCLK
set_property PACKAGE_PIN H4 [get_ports sysclk]

# set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets sck_IBUF]