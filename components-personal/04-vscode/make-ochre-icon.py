#!/usr/bin/env python3
"""Recolor a PNG to ochre while preserving its original shading.

Converts every non-transparent pixel from RGB to HSV, overwrites the hue
with a fixed ochre reference hue, and keeps saturation/value untouched
before converting back to RGB. Since the source (the real VS Code logo) is
essentially one hue rendered at many different tints for its folded-ribbon
look, replacing only the hue keeps that whole gradient/shading structure
intact while recoloring the icon.

Usage: make-ochre-icon.py <input.png> <output.png>
"""
import colorsys
import sys

from PIL import Image

OCHRE_REFERENCE_RGB = (0xCC, 0x77, 0x22)  # #CC7722


def main() -> None:
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} <input.png> <output.png>", file=sys.stderr)
        raise SystemExit(1)

    src_path, dest_path = sys.argv[1], sys.argv[2]
    target_hue, _, _ = colorsys.rgb_to_hsv(*(c / 255 for c in OCHRE_REFERENCE_RGB))

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
