import esp_brookesia as brookesia
import dashboard.ui_images as ui_images
import main

class App(brookesia.PhoneApp):
    def __init__(self):
        super().__init__("Dashboard", ui_images.ui_img_image_app_ebike_png, False)
        self.register_run_callback(self.run)
        self.register_back_callback(self.back)

    def run(void):
        print("Running")
        import dashboard.ui

    def back(void):
        print("Back")

print("Installing Dashboard app")
main.get_phone_instance().install_app(App())
