"""Measure a reference image and compare a build against it. Needs Pillow (pip install pillow).

    python refkit.py palette ref.png [N]          main colours as hex with their share of the image (default 8)
    python refkit.py pick ref.png X Y             exact colour at one pixel
    python refkit.py compare ref.png shot.png out.png
                                                  side by side (reference | build | difference heat map),
                                                  plus the share of pixels that differ visibly
    python refkit.py self-test
"""
import sys

try:
    from PIL import Image, ImageChops, ImageOps
except ImportError:
    sys.exit("refkit needs Pillow: pip install pillow")


def hexof(rgb) -> str:
    return "#%02x%02x%02x" % tuple(rgb[:3])


def palette(path: str, n: int = 8) -> list[tuple[str, float]]:
    im = Image.open(path).convert("RGB")
    im.thumbnail((400, 400))  # speed; proportions of colour survive
    # Octree keeps small saturated accents that median cut blends into neighbours; then merge near-duplicates.
    q = im.quantize(colors=32, method=Image.Quantize.FASTOCTREE)
    pal = q.getpalette()
    total = im.width * im.height
    merged: list[list] = []  # [rgb, count]
    for count, i in sorted(q.getcolors(), reverse=True):
        rgb = pal[i * 3:i * 3 + 3]
        near = next((m for m in merged if sum(abs(a - b) for a, b in zip(m[0], rgb)) < 30), None)
        if near:
            near[1] += count
        else:
            merged.append([rgb, count])
    merged.sort(key=lambda m: -m[1])
    return [(hexof(rgb), round(100 * c / total, 1)) for rgb, c in merged[:n]]


def pick(path: str, x: int, y: int) -> str:
    return hexof(Image.open(path).convert("RGB").getpixel((x, y)))


def compare(ref_path: str, shot_path: str, out_path: str) -> float:
    ref = Image.open(ref_path).convert("RGB")
    shot = Image.open(shot_path).convert("RGB")
    if shot.size != ref.size:  # a 2x screenshot against a 1x build, or a slightly different height
        shot = shot.resize(ref.size, Image.LANCZOS)
    diff = ImageChops.difference(ref, shot).convert("L")
    changed = sum(diff.histogram()[25:]) / (ref.width * ref.height)
    heat = ImageOps.colorize(ImageOps.autocontrast(diff), black="#101010", white="#ff3b30")
    out = Image.new("RGB", (ref.width * 3, ref.height), "white")
    for i, im in enumerate((ref, shot, heat)):
        out.paste(im, (i * ref.width, 0))
    out.save(out_path)
    return round(100 * changed, 1)


def self_test() -> None:
    import os
    import tempfile
    with tempfile.TemporaryDirectory() as tmp:
        a, b, o = (os.path.join(tmp, n) for n in ("a.png", "b.png", "o.png"))
        im = Image.new("RGB", (100, 50), "#f4f5f2")
        im.paste((24, 33, 42), (0, 0, 50, 50))
        im.save(a)
        im.paste((244, 197, 66), (50, 0, 100, 50))
        im.resize((200, 100)).save(b)  # different size and right half changed
        top = dict(palette(a, 4))
        assert "#18212a" in top and "#f4f5f2" in top, top
        assert pick(a, 75, 10) == "#f4f5f2"
        share = compare(a, b, o)
        assert 45 <= share <= 55, share
        assert Image.open(o).size == (300, 50)
    print("self-test passed")


def main(argv: list[str]) -> None:
    if not argv or argv[0] in ("-h", "--help"):
        sys.exit(__doc__)
    cmd, args = argv[0], argv[1:]
    if cmd == "palette":
        for hx, share in palette(args[0], int(args[1]) if len(args) > 1 else 8):
            print(f"{hx}  {share}%")
    elif cmd == "pick":
        print(pick(args[0], int(args[1]), int(args[2])))
    elif cmd == "compare":
        share = compare(*args[:3])
        print(f"{share}% of pixels differ visibly; see {args[2]} (reference | build | differences)")
    elif cmd == "self-test":
        self_test()
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main(sys.argv[1:])
