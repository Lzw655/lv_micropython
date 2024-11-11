import esp_brookesia as brookesia
import smart_gadget.ui_images as ui_images
import main

class App(brookesia.PhoneApp):
    def __init__(self):
        super().__init__("Smart Gadget", ui_images.ui_img_sls_logo_png, False)
        self.register_run_callback(self.run)
        self.register_back_callback(self.back)

    def run(void):
        print("Running")
        import smart_gadget.ui

    def back(void):
        print("Back")

print("Installing Smart Gadget app")
app = App()
main.get_phone_instance().install_app(app)
