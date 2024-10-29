import time
import os
import _thread
import lvgl as lv
import SDL
import esp_brookesia as brookesia

def run_python_file(file_path):
    with open(file_path) as f:
        code = f.read()
        exec(code)

if __name__ == '__main__':
    # Initialize LVGL and SDL
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
    disp_drv.hor_res = 800
    disp_drv.ver_res = 480
    disp_drv.register()

    # Regsiter SDL mouse driver
    indev_drv = lv.indev_drv_t()
    indev_drv.init()
    indev_drv.type = lv.INDEV_TYPE.POINTER
    indev_drv.read_cb = SDL.mouse_read
    indev_drv.register()

    # Create esp-brookesia phone object
    brookesia.create_phone()

    directory = "./scripts"
    exclude_file = "main.py"
    file_mod_times = {}

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
