import esp_brookesia as brookesia
import ebike.ui_images as ui_images
import main

class App(brookesia.PhoneApp):
    def __init__(self):
        super().__init__("Dashboard", ui_images.ui_img_image_app_ebike_png, False)
        self.register_run_callback(self.run)
        self.register_back_callback(self.back)

    def run(void):
        print("Running")
        import ebike.ui

    def back(void):
        print("Back")

print("Installing Dashboard app")
main.get_phone_instance().install_app(App())
