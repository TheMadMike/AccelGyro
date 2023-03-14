#include <stdio.h>
#include <string.h>
#include "xfpga/boot.h"

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "nvs_flash.h"

#include "driver/spi_slave.h"
#include "driver/gpio.h"

#define GPIO_MOSI 23
#define GPIO_MISO 19
#define GPIO_SCLK 18
#define GPIO_CS   5

#define RCV_HOST    SPI2_HOST


void app_main(void)
{
    xfpgaBootFromSDCard();

    // esp_err_t ret = nvs_flash_init();
    // if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
    //   ESP_ERROR_CHECK(nvs_flash_erase());
    //   ret = nvs_flash_init();
    // }

    esp_err_t ret;
    //Configuration for the SPI bus
    spi_bus_config_t buscfg={
        .mosi_io_num=GPIO_MOSI,
        .miso_io_num=GPIO_MISO,
        .sclk_io_num=GPIO_SCLK,
        .quadwp_io_num = -1,
        .quadhd_io_num = -1,
    };

    //Configuration for the SPI slave interface
    spi_slave_interface_config_t slvcfg={
        .mode=1,
        .spics_io_num=GPIO_CS,
        .queue_size=1,
        .flags=0,
        .post_setup_cb=NULL,
        .post_trans_cb=NULL
    };
    //Enable pull-ups on SPI lines so we don't detect rogue pulses when no master is connected.
    gpio_set_pull_mode(GPIO_MOSI, GPIO_PULLUP_ONLY);
    gpio_set_pull_mode(GPIO_SCLK, GPIO_PULLUP_ONLY);
    gpio_set_pull_mode(GPIO_CS, GPIO_PULLUP_ONLY);

    //Initialize SPI slave interface
    ret=spi_slave_initialize(RCV_HOST, &buscfg, &slvcfg, SPI_DMA_DISABLED);
    assert(ret==ESP_OK);

    WORD_ALIGNED_ATTR char recvbuf[8] = "";
    WORD_ALIGNED_ATTR char sendbuf[8] = "";
    memset(recvbuf, 0, 8);
    spi_slave_transaction_t t;
    memset(&t, 0, sizeof(t));

    t.length = 8;
    t.trans_len = 8;
    t.rx_buffer = recvbuf;
    t.tx_buffer = sendbuf;

    while(1) {

        ret = spi_slave_transmit(RCV_HOST, &t, 0xFFFF);
        if(ret != ESP_ERR_INVALID_ARG) {
            for(uint8_t i = 0; i < 8; ++i) {
                printf("%02x", recvbuf[i]);
            }
        }
    }
}
