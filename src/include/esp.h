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


#ifndef ESP_H
#define ESP_H

#define ESP_OK 0      // OK.
#define ESP_E_MEM 100 // Out of memory.
#define ESP_E_ARG 101 // Bad argument.
#define ESP_E_LOG 102 // Logic error.
#define ESP_E_SYS 103 // System error.
#define ESP_E_WIF 104 // WiFi error.
#define ESP_E_NET 105 // TCP/IP error.

#ifndef UNUSED
    #define UNUSED(x) ((void)(x))
#endif

#if defined(DEBUG_ON)
    #define ESP_DEBUG(format, ...) os_printf("ESP DBG: " format "\n", ## __VA_ARGS__ )
#endif

#endif //ESP_H
