#!/usr/bin/env python3
"""Measure grey panel bounding boxes in assets/images/car_diagram.png.

Outputs debugPrint lines matching the in-app tap calibrator format:
  PANEL {id}: left=X top=Y w=W h=H

Side doors/fenders use equal vertical splits (y=47–341) because the PNG has
no black gaps between those panels — only outline strokes.
"""
from __future__ import annotations

from PIL import Image

PANEL_ORDER = [
    'front_bumper',
    'hood',
    'front_left_fender',
    'front_right_fender',
    'front_left_door',
    'front_right_door',
    'roof',
    'rear_left_door',
    'rear_right_door',
    'rear_left_fender',
    'rear_right_fender',
    'trunk',
    'rear_bumper',
]


def is_grey(r: int, g: int, b: int) -> bool:
    return abs(r - g) < 25 and abs(g - b) < 25 and 140 < r < 230


def bbox_grey(img: Image.Image, x0: int, y0: int, x1: int, y1: int) -> tuple[int, int, int, int] | None:
    w, h = img.size
    px = img.load()
    minx, miny, maxx, maxy = x1, y1, x0, y0
    found = False
    for y in range(max(0, y0), min(h, y1 + 1)):
        for x in range(max(0, x0), min(w, x1 + 1)):
            r, g, b = px[x, y]
            if is_grey(r, g, b):
                found = True
                minx = min(minx, x)
                maxx = max(maxx, x)
                miny = min(miny, y)
                maxy = max(maxy, y)
    if not found:
        return None
    return minx, miny, maxx - minx + 1, maxy - miny + 1


def panel_regions(width: int, height: int) -> dict[str, tuple[int, int, int, int]]:
    y0, y1 = 47, 341
    seg = (y1 - y0 + 1) / 4
    splits = [int(y0 + i * seg) for i in range(5)]
    splits[-1] = y1

    return {
        'front_bumper': (0, 2, width - 1, 11),
        'hood': (97, 14, 214, 39),
        'front_left_fender': (0, splits[0], 110, splits[1] - 1),
        'front_right_fender': (205, splits[0], width - 1, splits[1] - 1),
        'front_left_door': (0, splits[1], 110, splits[2] - 1),
        'front_right_door': (205, splits[1], width - 1, splits[2] - 1),
        'roof': (97, 120, 214, 280),
        'rear_left_door': (0, splits[2], 110, splits[3] - 1),
        'rear_right_door': (205, splits[2], width - 1, splits[3] - 1),
        'rear_left_fender': (0, splits[3], 110, splits[4]),
        'rear_right_fender': (205, splits[3], width - 1, splits[4]),
        'trunk': (97, 350, 214, 375),
        'rear_bumper': (97, 378, 214, 387),
    }


def main() -> None:
    img = Image.open('assets/images/car_diagram.png').convert('RGB')
    w, h = img.size
    print(f'// car_diagram.png {w}x{h}')
    regions = panel_regions(w, h)
    for panel_id in PANEL_ORDER:
        region = regions[panel_id]
        bbox = bbox_grey(img, *region)
        if bbox is None:
            print(f'// PANEL {panel_id}: NOT FOUND')
            continue
        x, y, bw, bh = bbox
        left = x / w
        top = y / h
        width_pct = bw / w
        height_pct = bh / h
        print(
            f"debugPrint('PANEL {panel_id}: left={left:.3f} top={top:.3f} "
            f"w={width_pct:.3f} h={height_pct:.3f}');"
        )


if __name__ == '__main__':
    main()
