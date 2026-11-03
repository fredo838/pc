#!/usr/bin/env python3
"""Recolor a PNG to one hue while preserving its original shading.

Converts every non-transparent pixel from RGB to HSV, overwrites the hue
with the reference colour's hue (ochre unless given), and keeps saturation/value untouched
before converting back to RGB. Since the source (the real VS Code logo) is
essentially one hue rendered at many different tints for its folded-ribbon
look, replacing only the hue keeps that whole gradient/shading structure
intact while recoloring the icon.

Each self-built VS Code profile gets its own colour: Personal ochre (CC7722),
IoT teal (1F9E89).

Usage: recolour-icon.py <input.png> <output.png> [RRGGBB]
"""
import colorsys
import sys

from PIL import Image

OCHRE_REFERENCE_RGB = (0xCC, 0x77, 0x22)  # #CC7722


def main() -> None:
    if len(sys.argv) not in (3, 4):
        print(f"usage: {sys.argv[0]} <input.png> <output.png> [RRGGBB]", file=sys.stderr)
        raise SystemExit(1)

    src_path, dest_path = sys.argv[1], sys.argv[2]
    reference = OCHRE_REFERENCE_RGB
    if len(sys.argv) == 4:
        hex_colour = sys.argv[3].lstrip("#")
        reference = tuple(int(hex_colour[i:i + 2], 16) for i in (0, 2, 4))
    target_hue, _, _ = colorsys.rgb_to_hsv(*(c / 255 for c in reference))

    img = Image.open(src_path).convert("RGBA")
    pixels = img.load()
    width, height = img.size
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if a == 0:
                continue
            _, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
            nr, ng, nb = colorsys.hsv_to_rgb(target_hue, s, v)
            pixels[x, y] = (round(nr * 255), round(ng * 255), round(nb * 255), a)

    img.save(dest_path)


if __name__ == "__main__":
    main()
