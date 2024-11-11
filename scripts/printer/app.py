import esp_brookesia as brookesia
import printer.ui_images as ui_images
import main

class App(brookesia.PhoneApp):
    def __init__(self):
        super().__init__("3D Printer", ui_images.ui_img_image_app_3d_printer_png, False)
        self.register_run_callback(self.run)
        self.register_back_callback(self.back)

    def run(void):
        print("Running")
        import printer.ui

    def back(void):
        print("Back")

print("Installing 3D printer app")
main.get_phone_instance().install_app(App())
