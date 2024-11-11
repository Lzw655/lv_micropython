import time
import os
import gc
import _thread
import lvgl as lv
import lv_utils
import esp_brookesia as brookesia
from display_driver_utils import driver
import fs_driver

phone = None

def get_phone_instance():
    global phone

    if phone is None:
        print("Initializing ESP-Brookesia phone...")
        phone = brookesia.Phone()
        phone.begin()

    return phone

if __name__ == '__main__':
    print("Initializing LVGL...")
    lv.init()
    print("Initializing SDL...")
    drv = driver(800, 480)
    print("Initializing FS...")
    fs_drv = lv.fs_drv_t()
    fs_driver.fs_register(fs_drv, 'A')
    print( "Free memory: " + str(gc.mem_free()) )

    # get_phone_instance()
    # print( "Free memory: " + str(gc.mem_free()) )
