import os
import subprocess
import time
from PIL import Image
import shutil

VIDEO_PATH = "/home/rain/Video's/badapple.mp4"
FRAME_DIR = "/tmp/badapple_frames_bw"
AUDIO_PATH = "/tmp/badapple_audio.aac"

FRAME_RATE = 30

def clear_screen():
    os.system('clear')

def get_terminal_size():
    size = shutil.get_terminal_size(fallback=(80, 24))
    return size.columns, size.lines

def get_scaled_dimensions_fit_16_9(term_width, term_height, char_aspect=0.5):
    term_pixel_width = term_width
    term_pixel_height = term_height * 2 / char_aspect  # 2 pixels per char row

    target_aspect = 16 / 9
    term_aspect = term_pixel_width / term_pixel_height

    if term_aspect > target_aspect:
        scaled_height = int(term_pixel_height)
        scaled_width = int(scaled_height * target_aspect)
    else:
        scaled_width = int(term_pixel_width)
        scaled_height = int(scaled_width / target_aspect)

    return scaled_width, scaled_height

def extract_frames(width, height):
    os.makedirs(FRAME_DIR, exist_ok=True)

    subprocess.run([
        "ffmpeg", "-y", "-i", VIDEO_PATH,
        "-vf", f"scale={width}:{height}:flags=neighbor",
        "-q:v", "1",
        f"{FRAME_DIR}/frame_%04d.png"
    ], check=True)

    subprocess.run([
        "ffmpeg", "-y", "-i", VIDEO_PATH,
        "-vn",
        "-acodec", "copy",
        AUDIO_PATH
    ], check=True)

def play_audio():
    return subprocess.Popen(["mpv", "--no-video", AUDIO_PATH], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def image_to_bw_blocks(image):
    bw = image.convert("1")
    pixels = bw.load()
    width, height = bw.size

    lines = []
    y = 0
    while y < height:
        line = []
        for x in range(width):
            top = pixels[x, y]
            bottom = pixels[x, y + 1] if (y + 1) < height else 255

            if top == 0 and bottom == 0:
                char = '█'
            elif top == 0 and bottom != 0:
                char = '▀'
            elif top != 0 and bottom == 0:
                char = '▄'
            else:
                char = ' '
            line.append(char)
        lines.append("".join(line))
        y += 2
    return "\n".join(lines)

def main():
    term_width, term_height = get_terminal_size()
    print(f"Terminal size: {term_width}x{term_height} chars")

    char_aspect_ratio = 0.5

    scaled_width, scaled_height = get_scaled_dimensions_fit_16_9(
        term_width, term_height, char_aspect_ratio
    )

    print(f"Extracting frames scaled to {scaled_width}x{scaled_height} pixels (16:9 fit, half-block chars)...")
    extract_frames(scaled_width, scaled_height)

    audio_proc = play_audio()

    frame_files = sorted(os.listdir(FRAME_DIR))
    frame_duration = 1 / FRAME_RATE
    start_time = time.time()

    for i, frame_file in enumerate(frame_files):
        frame_path = os.path.join(FRAME_DIR, frame_file)
        image = Image.open(frame_path)

        output = image_to_bw_blocks(image)
        clear_screen()
        print(output)

        elapsed = time.time() - start_time
        expected = i * frame_duration
        to_sleep = expected - elapsed
        if to_sleep > 0:
            time.sleep(to_sleep)

    audio_proc.wait()

if __name__ == "__main__":
    main()
