import time
import os
import gc
import _thread
import lvgl as lv
import lv_utils
import esp_brookesia as brookesia
from display_driver_utils import driver

def run_python_file(file_path):
    with open(file_path) as f:
        code = f.read()
        exec(code)

# if __name__ == '__main__':

# Initialize LVGL and SDL
print("Initializing LVGL and SDL...")
lv.init()
drv = driver(800, 480)

print( "Free memory: " + str(gc.mem_free()) )

# import ui
import ui_images

class AppTest(brookesia.PhoneApp):
    def __init__(self):
        super().__init__("test", ui_images.ui_img_weather_1_png, True)
        self.register_run_callback(self.run)
        self.register_back_callback(self.back)

    def run(void):
        print("Running")

    def back(void):
        print("Back")

phone = brookesia.Phone()
phone.begin()

app_test = AppTest()
phone.install_app(app_test)

print( "Free memory: " + str(gc.mem_free()) )

    # Create esp-brookesia phone object
    # brookesia.create_phone()

    # directory = "./"
    # exclude_file = ["main.py", "ui_images.py"]
    # file_mod_times = {}

    # while True:
    #     try:
    #         for filename in os.listdir(directory):
    #             if filename.endswith(".py") and filename not in exclude_file:
    #                 file_path = directory + "/" + filename
    #                 stat = os.stat(file_path)
    #                 last_mod_time = stat[8]

    #                 if file_path not in file_mod_times or file_mod_times[file_path] != last_mod_time:
    #                     file_mod_times[file_path] = last_mod_time

    #                     print(f"Detected change in {file_path}. Running...")
    #                     _thread.start_new_thread(run_python_file, (file_path,))

    #         time.sleep(1)

    #     except Exception as e:
    #         print("Error:", e)
