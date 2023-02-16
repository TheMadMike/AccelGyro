#include "boot.h"

#include <sys/unistd.h>
#include <sys/stat.h>

#include "driver/gpio.h"
#include "soc/gpio_reg.h"

#define READ_SIZE 256

#include <dirent.h>
#include "esp_vfs_fat.h"
#include "driver/sdmmc_host.h"
#include "driver/sdmmc_defs.h"
#include "sdmmc_cmd.h"
#include "soc/sdmmc_pins.h"
#include "ff.h"

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"


#ifndef BOARD_MAX_SDMMC_FREQ
#define BOARD_MAX_SDMMC_FREQ SDMMC_FREQ_HIGHSPEED
#endif

static void xfpgaBootInitGPIO(void);

static gpio_config_t outputConfig, inputConfig;
static char* taskName;
static const char* mountpoint = "/sdcard";

void xfpgaBootFromSDCard(void) {
    /* get the task name */
    taskName = pcTaskGetName(NULL); 

    /* initialize proper gpio pins */
    xfpgaBootInitGPIO();

    ESP_LOGI(taskName, "Loading the bitstream...\n");
    sdmmc_slot_config_t slotConfig = SDMMC_SLOT_CONFIG_DEFAULT();

    slotConfig.width = 4;

    sdmmc_host_t host = SDMMC_HOST_DEFAULT();
    host.flags = SDMMC_HOST_FLAG_4BIT;
    host.slot = SDMMC_HOST_SLOT_1;
    host.max_freq_khz = BOARD_MAX_SDMMC_FREQ;

    esp_vfs_fat_sdmmc_mount_config_t mountConfig;
    mountConfig.format_if_mount_failed = false;
    mountConfig.max_files = 5;
    mountConfig.allocation_unit_size = 0;

    sdmmc_card_t* card = NULL;

    esp_err_t retValue = esp_vfs_fat_sdmmc_mount(mountpoint, 
        &host,
        &slotConfig,
        &mountConfig,
        &card
    );

    if(retValue != ESP_OK) {
        ESP_LOGE(taskName, "SDCard: Failed to mount filesystem.");
        return;
    }

    ESP_LOGI(taskName, "Filesystem mounted\n");

    unsigned char buffer[1024];
    size_t len;
    unsigned byte;

    FILE* file = fopen(BITSTREAM_PATH, "r");
    if(file == NULL) {
        ESP_LOGE(taskName, "Failed to load the default bitstream.\n");
        return;
    }

    len = fread(buffer, 1, READ_SIZE, file);

    size_t i = 0, j = 0;

    if(buffer[0] != 0xff){

        i = ((buffer[0] << 8) | buffer[1]) + 4;

        while(buffer[i] != 0x65) {
            i += (buffer[i+1] << 8 | buffer[i+2]) + 3;
            
            if(i >= len){
                ESP_LOGE(taskName, "Error loading the bitstream\n");
                return;
            }
        }
        i += 5;
    }

    ESP_LOGI(taskName, "Uploading the bitstream...\n");

    gpio_set_direction(XFPGA_DIN_PIN, GPIO_MODE_OUTPUT);

    while ((len != 0)&&(len != -1)) {
        for ( ;i < len;i++) {
            byte = buffer[i];

            for(j = 0;j < 8;j++) {
                REG_WRITE(GPIO_OUT_W1TC_REG, (1<<XFPGA_CCLK_PIN));
                REG_WRITE((byte&0x80)?GPIO_OUT_W1TS_REG:GPIO_OUT_W1TC_REG, (1<<XFPGA_DIN_PIN));
                byte = byte << 1;
                REG_WRITE(GPIO_OUT_W1TS_REG, (1<<XFPGA_CCLK_PIN));
            }
        }
        len = fread(buffer, 1, READ_SIZE, file);
        i = 0;
    }

    gpio_set_level(XFPGA_CCLK_PIN, 0);

    

    fclose(file);
    
    if(gpio_get_level(XFPGA_DONE_PIN) == 0) {
        ESP_LOGE(taskName, "FPGA configuration failed!\n");
    } else {
        ESP_LOGI(taskName, "FPGA configuration success!\n");
    }

    esp_vfs_fat_sdmmc_unmount();
    ESP_LOGI(taskName, "Filesystem unmounted\n");
}


void xfpgaBootInitGPIO(void) {
    ESP_LOGI(taskName, "Initializing GPIO for the FPGA boot...\n");

    /* set input pins */
    inputConfig.pin_bit_mask = (1ULL << XFPGA_INTB_PIN) 
                             | (1ULL << XFPGA_DONE_PIN);

    /* set output pins */
    outputConfig.pin_bit_mask = (1ULL << XFPGA_PROGRAM_PIN)
                              | (1ULL << XFPGA_CCLK_PIN);

    /* set gpio modes for each config */
    inputConfig.mode = GPIO_MODE_INPUT;
    outputConfig.mode = GPIO_MODE_OUTPUT;

    /* apply the config */
    gpio_config(&inputConfig);
    gpio_config(&outputConfig);

    
    // ESP GPIO2        (pin 22) <---> SD CARD D0
    // ESP GPIO4        (pin 24) <---> SD CARD D1
    // ESP GPIO12/MTDI  (pin 18) <---> SD CARD D2
    // ESP GPIO13/MTCK  (pin 20) <---> SD CARD D3
    // ESP GPIO15/MTDO  (pin 21) <---> SD CARD CMD

    /* pull up the SD card pins */
    gpio_pullup_en(GPIO_NUM_2);
    gpio_pullup_en(GPIO_NUM_4);
    gpio_pullup_en(GPIO_NUM_12);
    gpio_pullup_en(GPIO_NUM_13);
    gpio_pullup_en(GPIO_NUM_15);


    /* set the initial logic levels on specific pins */
    gpio_set_level(XFPGA_PROGRAM_PIN, 0);
    gpio_set_level(XFPGA_CCLK_PIN, 0);
    gpio_set_level(XFPGA_PROGRAM_PIN, 1);

    /* the previous gpio logic level sets trigger a FPGA reset */
    /* wait until FPGA resets */
    while(gpio_get_level(XFPGA_INTB_PIN) == 0) {
        vTaskDelay(1);
    }
}