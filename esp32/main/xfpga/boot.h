#ifndef XFPGA_BOOT
#define XFPGA_BOOT

/* pin configurations */
#define XFPGA_CCLK_PIN 17
#define XFPGA_DIN_PIN 27
#define XFPGA_PROGRAM_PIN 25
#define XFPGA_INTB_PIN 26
#define XFPGA_DONE_PIN 34

#define BITSTREAM_PATH "/sdcard/overlay/default.bit"

/**
 * @brief Loads a bistream from an SD card 
 * from the card slot on the board ()
 */
void xfpgaBootFromSDCard(void);

#endif /* XFPGA_BOOT */