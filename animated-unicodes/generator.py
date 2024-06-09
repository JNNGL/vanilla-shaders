#!/usr/bin/python3

import math
import argparse
from PIL import Image


def build_frames(gif, animation_seconds):
    num_frames = math.floor(gif.n_frames)
    frame_width, frame_height = gif.size
    frames_per_line = math.ceil(math.sqrt(num_frames))
    frame_dim = max(frame_width, frame_height)
    width = frames_per_line * frame_dim + 2
    height = frames_per_line * frame_dim + 2
    frames = Image.new("RGBA", (width, height), color=(0, 0, 0, 0))
    for i in range(num_frames):
        gif.seek(i)
        frame = gif.copy()
        aligned_frame = Image.new("RGBA", (frame_dim, frame_dim), color=(0, 0, 0, 0))
        aligned_frame.paste(frame, (0, 0))
        frames.paste(aligned_frame,
                     ((i % frames_per_line) * frame_dim + 1, math.floor(i / frames_per_line) * frame_dim + 1),
                     aligned_frame)
    frames.putpixel((0, 0), (149, 213, 75, 1))
    frames.putpixel((1, 0), (width, height, 75, 1))
    frames.putpixel((2, 0), (frame_dim, num_frames, 75, 1))
    s = math.floor(animation_seconds)
    frames.putpixel((3, 0), (s, math.floor((animation_seconds - s) * 255.0), 75, 1))
    frames.putpixel((width - 1, 0), (width - 1, 0, 75, 1))
    frames.putpixel((0, height - 1), (0, height - 1, 75, 1))
    frames.putpixel((width - 1, height - 1), (width - 1, height - 1, 75, 1))
    return frames


parser = argparse.ArgumentParser(prog='generator', description='')
parser.add_argument('--input')
parser.add_argument('--duration', type=float)
parser.add_argument('--output')

args = parser.parse_args()

frames = build_frames(Image.open(args.input), args.duration)
frames.save(args.output, format='PNG')