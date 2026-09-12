"""Render the profile card preview from scripts/profile_panel_preview.luau.

Usage: python3 scripts/render_profile_panel_preview.py [dump.json] [out-dir]
Needs Pillow; fonts fall back to whatever DejaVu the machine has.
"""
import json, glob, os, sys
from PIL import Image, ImageDraw, ImageFont

DUMP = sys.argv[1] if len(sys.argv) > 1 else '/tmp/panel_dumps.txt'
OUT_DIR = sys.argv[2] if len(sys.argv) > 2 else '.'

TTF = sorted(glob.glob('/usr/share/fonts/**/*.ttf', recursive=True))
PLAIN = [c for c in TTF if 'Mono' not in c and 'Serif' not in c and 'Bold' not in c]
_cache = {}
def font(size):
    if size not in _cache:
        _cache[size] = ImageFont.truetype(PLAIN[0], size) if PLAIN else ImageFont.load_default()
    return _cache[size]

SCALE = 2
BG = (46, 44, 52)
# [[DejaVu is wider than the game's Gotham, so draw text a little smaller: the
# [[preview then reads at roughly the game's proportions instead of looking
# [[cramped (the real layout is measured by functions.textWidth).]]
TEXT_SCALE = 0.8

def render(data, path_out):
    root = data
    # the stub reports the root's absolute position already, and the shell is
    # what positions the card, so start the walk from that exact origin
    root['pos'] = [0.0, 0.0, 0.0, 0.0]
    root['anchor'] = [0.0, 0.0]
    root_x, root_y = root['x'], root['y']
    W = int(root['size'][1] * SCALE) + 60
    H = int(root['size'][3] * SCALE) + 60
    img = Image.new('RGB', (W, H), BG)
    draw = ImageDraw.Draw(img, 'RGBA')

    def geometry(n, px, py, pw, ph):
        sx, ox, sy, oy = n['pos']
        w = n['size'][0] * pw + n['size'][1]
        h = n['size'][2] * ph + n['size'][3]
        ax, ay = n['anchor']
        x = px + sx * pw + ox - ax * w
        y = py + sy * ph + oy - ay * h
        return x, y, w, h

    def draw_node(n, px, py, pw, ph, clip):
        if not n['visible']:
            return
        x, y, w, h = geometry(n, px, py, pw, ph)
        sx = (x - root_x) * SCALE + 30
        sy = (y - root_y) * SCALE + 30
        sw, sh = w * SCALE, h * SCALE
        cls = n['class']
        r = 0
        if n['corner']:
            scale, offset = n['corner']
            r = min(sw, sh) / 2 if scale >= 1 else offset * SCALE
        visible = clip is None or not (sx > clip[2] or sy > clip[3] or sx + sw < clip[0] or sy + sh < clip[1])
        if visible:
            if cls == 'ImageLabel' and n['imageTransparency'] < 1:
                draw.rounded_rectangle([sx, sy, sx + sw, sy + sh], radius=max(2, r),
                                       fill=(28, 32, 38, 255), outline=(64, 72, 84, 255), width=1)
                draw.text((sx + sw / 2, sy + sh / 2), '\u25a3', font=font(max(9, int(sh * 0.5))),
                          fill=(125, 136, 150, 255), anchor='mm')
            bg = n['color']
            alpha = 1 - n['backgroundTransparency']
            if bg and alpha > 0:
                col = tuple(int(round(v * 255)) for v in bg) + (int(alpha * 255),)
                if r > 0:
                    draw.rounded_rectangle([sx, sy, sx + sw, sy + sh], radius=r, fill=col)
                else:
                    draw.rectangle([sx, sy, sx + sw, sy + sh], fill=col)
            if n['gradient']:
                c1 = tuple(int(round(v * 255)) for v in n['gradient'][:3])
                c2 = tuple(int(round(v * 255)) for v in n['gradient'][3:])
                for i in range(max(1, int(sh))):
                    t = i / max(1, int(sh) - 1)
                    col = tuple(int(c1[k] + (c2[k] - c1[k]) * t) for k in range(3))
                    draw.line([(sx, sy + i), (sx + sw, sy + i)], fill=col + (int(alpha * 255),))
            if n['stroke']:
                sr, sg, sb, st = n['stroke']
                col = (int(sr * 255), int(sg * 255), int(sb * 255), int((1 - st) * 255))
                if r > 0:
                    draw.rounded_rectangle([sx, sy, sx + sw, sy + sh], radius=r, outline=col, width=SCALE)
                else:
                    draw.rectangle([sx, sy, sx + sw, sy + sh], outline=col, width=SCALE)
            if cls in ('TextLabel', 'TextButton') and n['text'] and n['textTransparency'] < 1:
                tc = n['textColor'] or [1, 1, 1]
                col = (int(tc[0] * 255), int(tc[1] * 255), int(tc[2] * 255), int((1 - n['textTransparency']) * 255))
                size = max(8, int(round(n['textSize'] * SCALE * TEXT_SCALE)))
                f = font(size)
                tw = draw.textlength(n['text'], font=f)
                tx = sx + (sw - tw) / 2 if n['align'] == 'Center' else (sx + sw - tw if n['align'] == 'Right' else sx)
                ascent, descent = f.getmetrics()
                ty = sy + (sh - (ascent + descent)) / 2
                draw.text((tx, ty), n['text'], font=f, fill=col)
        child_clip = clip
        if n['name'] in ('Details', 'Content') and n['class'] == 'ScrollingFrame':
            child_clip = (sx, sy, sx + sw, sy + sh) if clip is None else \
                         (max(clip[0], sx), max(clip[1], sy), min(clip[2], sx + sw), min(clip[3], sy + sh))
        cw, ch = w, h
        for c in n['children']:
            draw_node(c, x, y, cw, ch, child_clip)

    draw_node(root, root_x, root_y, root['size'][1], root['size'][3], None)
    img.save(path_out)
    print('rendered', path_out, img.size)

def load_dumps():
    """The dump prints PAYLOAD / MASKED / REVEALED labels around the JSON."""
    found = {}
    pending = None
    for line in open(DUMP, encoding='utf-8'):
        line = line.strip()
        if line in ('MASKED', 'REVEALED'):
            pending = line.lower()
        elif pending and line.startswith('{'):
            found[pending] = json.loads(line)
            pending = None
    return found

dumps = load_dumps()
for name, payload in dumps.items():
    out = os.path.join(OUT_DIR, 'profile-panel-preview' if name == 'masked' else 'profile-panel-preview-revealed')
    render(payload, out + '.png')
