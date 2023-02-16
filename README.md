# LSM6DS3 - 3D accelerometer and 3D gyroscope

**TL;DR:** [LSM6DS3](https://octopart.com/datasheet/lsm6ds3tr-stmicroelectronics-53586202) -> [XC7S15](https://octopart.com/datasheet/xc7s15-2cpga196i-xilinx-91997162) (reading, filtering) -> ESP32 (WiFi) 


The goal of this project is to read from the LSM6DS3 sensor,
and apply a real time FIR filter on the received data using 
a Xilinx Spartan 7 FPGA on [Spartan Edge Accelerator](https://wiki.seeedstudio.com/Spartan-Edge-Accelerator-Board/#spartan-edge-accelerator-board-esp32-boot) board with and utilizing the onboard ESP32 microcontroller to send the data over Wi-Fi or bluetooth.


For more info LSM6DS3, please refer to the [datasheet](https://octopart.com/datasheet/lsm6ds3tr-stmicroelectronics-53586202).
