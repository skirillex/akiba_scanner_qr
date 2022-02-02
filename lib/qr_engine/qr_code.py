import qrcode
from PIL import ImageDraw, ImageFont
import random
import sys



def generate_qr(output_path, num_of_qr):
    num_of_qr_codes = int(num_of_qr)

    for x in range(0,num_of_qr_codes):

        barcode_num = random.randint(100000,900000)
        # creating a QRCode object
        obj_qr = qrcode.QRCode(
            version = 1,
            error_correction = qrcode.constants.ERROR_CORRECT_H,
            box_size = 25,
            border = 4,
        )
        # using the add_data() function
        obj_qr.add_data(f"{barcode_num}")
        # using the make() function
        obj_qr.make(fit = True)
        # using the make_image() function
        qr_img = obj_qr.make_image(fill_color = "black", back_color = "white").convert("RGB")
        d = ImageDraw.Draw(qr_img)
        font = ImageFont.truetype("/Library/Fonts/Arial Unicode.ttf", 50)
        d.text((275,650), f"{barcode_num}", font=font, fill=(0))
        # saving the QR code image
        #Sqr_img.show()
        qr_img.save(f"{output_path}/{barcode_num}.png")
    
    sys.exit()
