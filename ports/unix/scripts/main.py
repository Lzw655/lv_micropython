import lvgl as lv
import SDL
import time

import os
import _thread
import esp_brookesia as brookesia

lv.init()
SDL.init()

# Register SDL display driver.

draw_buf = lv.disp_draw_buf_t()
buf1_1 = bytearray(480*10)
draw_buf.init(buf1_1, None, len(buf1_1)//4)
disp_drv = lv.disp_drv_t()
disp_drv.init()
disp_drv.draw_buf = draw_buf
disp_drv.flush_cb = SDL.monitor_flush
disp_drv.hor_res = 480
disp_drv.ver_res = 320
disp_drv.register()

# Regsiter SDL mouse driver

indev_drv = lv.indev_drv_t()
indev_drv.init()
indev_drv.type = lv.INDEV_TYPE.POINTER
indev_drv.read_cb = SDL.mouse_read
indev_drv.register()

# Create a screen with a button and a label

scr = lv.obj()
btn = lv.btn(scr)
btn.align_to(lv.scr_act(), lv.ALIGN.CENTER, 0, 0)
label = lv.label(btn)
label.set_text("Hello World!")

# Load the screen

lv.scr_load(scr)

# brookesia.create_phone()

# last_mtime = None
# filename = "./scripts/test.py"

# while True:
#     mtime = os.stat(filename)[8]  # 获取文件的最后修改时间
#     if last_mtime is None or mtime != last_mtime:
#         last_mtime = mtime
#         with open(filename) as f:
#             code = f.read()
#             exec(code)
#     time.sleep(1)

directory = "./scripts"
exclude_file = "main.py"

file_mod_times = {}

def run_python_file(file_path):
    with open(file_path) as f:
        code = f.read()
        exec(code)

while True:
    try:
        for filename in os.listdir(directory):
            if filename.endswith(".py") and filename != exclude_file:
                file_path = directory + "/" + filename
                stat = os.stat(file_path)
                last_mod_time = stat[8]

                if file_path not in file_mod_times or file_mod_times[file_path] != last_mod_time:
                    file_mod_times[file_path] = last_mod_time

                    print(f"Detected change in {file_path}. Restarting...")
                    _thread.start_new_thread(run_python_file, (file_path,))

        time.sleep(1)

    except Exception as e:
        print("Error:", e)
