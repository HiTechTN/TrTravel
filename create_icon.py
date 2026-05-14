import os
from PIL import Image, ImageDraw

# Define sizes for Android launcher icons (in pixels)
sizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
    # Also create a 512x512 for web/play store
    'playstore': 512
}

# Turkish Airlines red color
turkish_red = (227, 10, 23)  # #E30A17
white = (255, 255, 255)

def create_icon(size):
    # Create a transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw a circle background
    margin = size * 0.05
    circle_bbox = [margin, margin, size - margin, size - margin]
    draw.ellipse(circle_bbox, fill=turkish_red)
    
    # Draw a simplified airplane (white) in the center
    # We'll create a very simple airplane shape: a triangle for the body and two wings
    center = size // 2
    body_width = size * 0.1
    body_height = size * 0.3
    wing_width = size * 0.4
    wing_height = size * 0.08
    
    # Body (triangle pointing up)
    body_points = [
        (center, center - body_height//2),  # top
        (center - body_width//2, center + body_height//2),  # bottom left
        (center + body_width//2, center + body_height//2)   # bottom right
    ]
    draw.polygon(body_points, fill=white)
    
    # Wings (two rectangles)
    wing_left = [
        (center - wing_width//2 - body_width//2, center - wing_height//2),
        (center - wing_width//2 - body_width//2, center + wing_height//2),
        (center - body_width//2, center + wing_height//2),
        (center - body_width//2, center - wing_height//2)
    ]
    wing_right = [
        (center + body_width//2, center - wing_height//2),
        (center + body_width//2, center + wing_height//2),
        (center + wing_width//2 + body_width//2, center + wing_height//2),
        (center + wing_width//2 + body_width//2, center - wing_height//2)
    ]
    draw.polygon(wing_left, fill=white)
    draw.polygon(wing_right, fill=white)
    
    return img

for folder, size in sizes.items():
    if folder == 'playstore':
        # Save to assets/icons for now
        out_dir = os.path.join('assets', 'icons')
        os.makedirs(out_dir, exist_ok=True)
        filename = 'ic_launcher_playstore.png'
    else:
        out_dir = os.path.join('android', 'app', 'src', 'main', 'res', folder)
        filename = 'ic_launcher.png'
    
    img = create_icon(size)
    img.save(os.path.join(out_dir, filename))
    print(f'Generated {filename} in {out_dir} ({size}x{size})')
    
    # Also create round version if needed (same as square for now, but we can make a circle)
    if folder != 'playstore':
        round_filename = 'ic_launcher_round.png'
        # Create a circular mask
        mask = Image.new('L', (size, size), 0)
        mask_draw = ImageDraw.Draw(mask)
        mask_draw.ellipse((0, 0, size, size), fill=255)
        round_img = Image.composite(img, Image.new('RGBA', (size, size), (0,0,0,0)), mask)
        round_img.save(os.path.join(out_dir, round_filename))
        print(f'Generated {round_filename} in {out_dir} ({size}x{size})')

print('Done!')
