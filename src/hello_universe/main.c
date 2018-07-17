/*
 * Copyright 2018 Rafal Zajac <rzajac@gmail.com>.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may
 * not use this file except in compliance with the License. You may obtain
 * a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 */

#include <user_interface.h>
#include <osapi.h>

#define BIT_RATE_74880 74880

static void ICACHE_FLASH_ATTR
start()
{
    // No need for wifi for this example.
    wifi_station_disconnect();
    wifi_set_opmode_current(NULL_MODE);

    uint32 heap_size = system_get_free_heap_size();

    // Get MAC addresses.
    uint8 soft_ap_mac[6];
    uint8 station_mac[6];
    wifi_get_macaddr(SOFTAP_IF, soft_ap_mac);
    wifi_get_macaddr(STATION_IF, station_mac);

    os_printf("\n\n");

    os_printf("Hello Universe!\n");

    os_printf("\n\n");

    // System info.
    os_printf("Chip ID        : %d\n", system_get_chip_id());
    os_printf("CPU freq       : %d\n", system_get_cpu_freq());
    os_printf("free heap size : %d\n", heap_size);
    os_printf("SDK version    : %s\n", system_get_sdk_version());
    os_printf("Soft AP MAC    : "MACSTR"\n", MAC2STR(soft_ap_mac));
    os_printf("Station MAC    : "MACSTR"\n", MAC2STR(station_mac));

    os_printf("\n");

    system_print_meminfo();

    os_printf("\n");

    // Type sizes.
    os_printf("Type sizes in bytes.\n");
    os_printf("  char    : %d byte\n", sizeof(char));
    os_printf("  short   : %d bytes\n", sizeof(short));
    os_printf("  int     : %d bytes\n", sizeof(int));
    os_printf("  long    : %d bytes\n", sizeof(long));
    os_printf("  size_t  : %d bytes\n", sizeof(size_t));
    os_printf("  float   : %d bytes\n", sizeof(float));
    os_printf("  double  : %d bytes\n\n", sizeof(double));
    os_printf("  pointer : %d bytes\n", sizeof(int *));

    os_printf("\n\n");

    // MSB or LSB first.
    uint16_t i = 0xABCD;
    uint8_t *p = (uint8_t *) &i;

    if (*p == 0xAB) {
        os_printf("System is MSB first.\n");
    } else {
        os_printf("System is LSB first.\n");
    }

    os_printf("*p     : %X\n", *p);
    os_printf("*(p+1) : %X\n", *(p+1));
}

/**
 * The entry point to your program.
 *
 * Sets up UART and schedules call to user code.
 */
void ICACHE_FLASH_ATTR
user_init()
{
    // Initialize UART0.
    uart_div_modify(0, UART_CLK_FREQ / BIT_RATE_74880);

    system_init_done_cb(start);
}