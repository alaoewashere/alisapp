#!/usr/bin/env python3
"""Generate per-panel alpha masks from car_diagram.png grey pixels.

Side panels: connected-component y-bands (unchanged — working).
Center + bumpers: all grey pixels inside kCarPaintPanelLayouts bbox so paint
aligns with + button hit areas (hood/roof/trunk/bumpers).

Re-run after changing car_diagram.png or panel layout percentages.
"""
from __future__ import annotations

from collections import deque
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
DIAGRAM = ROOT / 'assets/images/car_diagram.png'
OUT_DIR = ROOT / 'assets/images/car_paint_masks'

# Must match kCarPaintPanelLayouts in car_paint_panel_layout.dart
PANEL_BBOX = {
    'front_bumper': (0.278, 0.005, 0.443, 0.095),
    'hood': (0.278, 0.117, 0.443, 0.199),
    'front_left_fender': (0.000, 0.117, 0.259, 0.219),
    'front_right_fender': (0.741, 0.117, 0.259, 0.219),
    'front_left_door': (0.000, 0.336, 0.259, 0.174),
    'front_right_door': (0.741, 0.336, 0.259, 0.174),
    'roof': (0.307, 0.510, 0.373, 0.149),  # flat grey between front/rear windshields
    'rear_left_door': (0.000, 0.510, 0.259, 0.162),
    'rear_right_door': (0.741, 0.510, 0.259, 0.162),
    'rear_left_fender': (0.000, 0.672, 0.259, 0.211),
    'rear_right_fender': (0.741, 0.672, 0.259, 0.211),
    'trunk': (0.278, 0.659, 0.443, 0.224),
    'rear_bumper': (0.278, 0.896, 0.443, 0.104),
}

PANEL_ORDER = list(PANEL_BBOX.keys())

CENTER_BBOX_PANELS = ('hood', 'roof', 'trunk', 'front_bumper', 'rear_bumper')


def is_grey(r: int, g: int, b: int) -> bool:
    return abs(r - g) < 25 and abs(g - b) < 25 and 140 < r < 230


def in_bbox(x: int, y: int, w: int, h: int, box: tuple[float, float, float, float]) -> bool:
    left, top, pw, ph = box
    return left * w <= x < (left + pw) * w and top * h <= y < (top + ph) * h


def y_range(h: int, top: float, ph: float) -> tuple[int, int]:
    return int(top * h), int((top + ph) * h)


def label_components(w: int, h: int, px) -> tuple[list[list[int]], dict[int, tuple[int, int, int, int, int]]]:
    comp_id = [[0] * w for _ in range(h)]
    comps: dict[int, tuple[int, int, int, int, int]] = {}
    cid = 0
    for sy in range(h):
        for sx in range(w):
            if comp_id[sy][sx] or not is_grey(*px[sx, sy]):
                continue
            cid += 1
            q = deque([(sx, sy)])
            comp_id[sy][sx] = cid
            n = 0
            minx = maxx = sx
            miny = maxy = sy
            while q:
                x, y = q.popleft()
                n += 1
                minx = min(minx, x)
                maxx = max(maxx, x)
                miny = min(miny, y)
                maxy = max(maxy, y)
                for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                    if 0 <= nx < w and 0 <= ny < h and not comp_id[ny][nx] and is_grey(*px[nx, ny]):
                        comp_id[ny][nx] = cid
                        q.append((nx, ny))
            comps[cid] = (n, minx, miny, maxx, maxy)
    return comp_id, comps


def find_comp(comps: dict[int, tuple[int, int, int, int, int]], w: int, h: int,
              left: float, top: float, pw: float, ph: float, min_area: int = 200) -> int | None:
    best = None
    best_dist = 999.0
    for cid, (n, minx, miny, maxx, maxy) in comps.items():
        if n < min_area:
            continue
        dist = abs(minx / w - left) + abs(miny / h - top)
        if dist < best_dist:
            best_dist = dist
            best = cid
    return best


def mask_bounds(mask: Image.Image) -> tuple[int, int, int, int, int] | None:
    px = mask.load()
    w, h = mask.size
    minx, miny, maxx, maxy = w, h, 0, 0
    n = 0
    for y in range(h):
        for x in range(w):
            if px[x, y][3] > 0:
                n += 1
                minx = min(minx, x)
                miny = min(miny, y)
                maxx = max(maxx, x)
                maxy = max(maxy, y)
    if n == 0:
        return None
    return n, minx, miny, maxx - minx + 1, maxy - miny + 1


def main() -> None:
    img = Image.open(DIAGRAM).convert('RGB')
    w, h = img.size
    px = img.load()
    comp_id, comps = label_components(w, h, px)

    left_comp = find_comp(comps, w, h, 0.054, 0.117, 0.272, 0.734)
    right_comp = find_comp(comps, w, h, 0.658, 0.117, 0.272, 0.734)
    fl_corner = find_comp(comps, w, h, 0.000, 0.201, 0.133, 0.104, min_area=500)
    fr_corner = find_comp(comps, w, h, 0.851, 0.201, 0.133, 0.104, min_area=500)
    rl_corner = find_comp(comps, w, h, 0.000, 0.652, 0.133, 0.104, min_area=500)
    rr_corner = find_comp(comps, w, h, 0.851, 0.652, 0.133, 0.104, min_area=500)

    side_y = {
        pid: y_range(h, PANEL_BBOX[pid][1], PANEL_BBOX[pid][3])
        for pid in (
            'front_left_fender', 'front_left_door', 'rear_left_door', 'rear_left_fender',
            'front_right_fender', 'front_right_door', 'rear_right_door', 'rear_right_fender',
        )
    }

    def side_panel_for(c: int, y: int) -> str | None:
        if c == fl_corner:
            return 'front_left_fender'
        if c == rl_corner:
            return 'rear_left_fender'
        if c == fr_corner:
            return 'front_right_fender'
        if c == rr_corner:
            return 'rear_right_fender'
        if c == left_comp:
            for pid in ('front_left_fender', 'front_left_door', 'rear_left_door', 'rear_left_fender'):
                y0, y1 = side_y[pid]
                if y0 <= y < y1:
                    return pid
            return None
        if c == right_comp:
            for pid in ('front_right_fender', 'front_right_door', 'rear_right_door', 'rear_right_fender'):
                y0, y1 = side_y[pid]
                if y0 <= y < y1:
                    return pid
            return None
        return None

    def center_bbox_panel_for(x: int, y: int) -> str | None:
        for pid in CENTER_BBOX_PANELS:
            if in_bbox(x, y, w, h, PANEL_BBOX[pid]):
                return pid
        return None

    def panel_for(x: int, y: int) -> str | None:
        if not is_grey(*px[x, y]):
            return None
        c = comp_id[y][x]
        side = side_panel_for(c, y)
        if side is not None:
            return side
        return center_bbox_panel_for(x, y)

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    print(f'// {DIAGRAM.name} {w}x{h}')
    print('// panel | mask_px | mask_bounds_pct | layout_bbox_pct')
    for panel_id in PANEL_ORDER:
        mask = Image.new('RGBA', (w, h), (0, 0, 0, 0))
        mpx = mask.load()
        for y in range(h):
            for x in range(w):
                if panel_for(x, y) == panel_id:
                    mpx[x, y] = (255, 255, 255, 255)
        out = OUT_DIR / f'{panel_id}.png'
        mask.save(out)
        b = mask_bounds(mask)
        lb = PANEL_BBOX[panel_id]
        if b:
            n, mx, my, bw, bh = b
            mp = f'({mx/w:.3f},{my/h:.3f},{bw/w:.3f},{bh/h:.3f})'
        else:
            n = 0
            mp = 'EMPTY'
        lp = f'({lb[0]:.3f},{lb[1]:.3f},{lb[2]:.3f},{lb[3]:.3f})'
        print(f'// {panel_id}: {n} px | mask {mp} | layout {lp}')


if __name__ == '__main__':
    main()
