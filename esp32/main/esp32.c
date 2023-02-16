#include <stdio.h>
#include "xfpga/boot.h"

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"

void app_main(void)
{
    xfpgaBootFromSDCard();

    while(1) {
        vTaskDelay(1000);
    }
}
