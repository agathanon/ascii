#!/usr/bin/env python3
"""Rewrite the gallery section of README.md from a list of art files (artist/title.txt)."""
import argparse
from html import escape
from itertools import groupby
from pathlib import Path
from urllib.parse import quote

START, END = "<!-- GALLERY:START -->", "<!-- GALLERY:END -->"

p = argparse.ArgumentParser()
p.add_argument("files", nargs="*")
p.add_argument("--img-dir", default=".img")
p.add_argument("--cols", type=int, default=3)
p.add_argument("--readme", default="README.md")
a = p.parse_args()

art = sorted(Path(f) for f in a.files)
img_dir = Path(a.img_dir)

def full(f):
    return img_dir / f.parent / f"{f.stem}.png"

def thumb(f):
    return img_dir / f.parent / f"{f.stem}_thumb.png"

# Remove generated images whose source .txt no longer exists. Orphans are found
# via .img/<dir>/*_thumb.png, and the matching full-size name.png goes with it;
# nothing else in .img is touched.
wanted = {thumb(f) for f in art}
for png in img_dir.glob("*/*_thumb.png"):
    if png not in wanted:
        sibling = png.with_name(png.name[:-len("_thumb.png")] + ".png")
        for victim in (png, sibling):
            if victim.exists():
                victim.unlink()
                print(f"pruned {victim}")

def cell(f):
    # Thumbnail links to the full-size PNG; the filename below links to the raw .txt
    # (?raw=true makes GitHub redirect the relative link to the raw file)
    name = escape(f.name)
    return (f"<td align=\"center\"><a href=\"{quote(full(f).as_posix())}\">"
            f"<img src=\"{quote(thumb(f).as_posix())}\" alt=\"{name}\"></a>"
            f"<br><a href=\"{quote(f.as_posix())}?raw=true\">{name}</a></td>")

sections = []
for artist, files in groupby(art, key=lambda f: f.parent.name):
    files = list(files)
    rows = [files[i:i + a.cols] for i in range(0, len(files), a.cols)]
    table = "\n".join(["<table>"]
                      + ["<tr>\n" + "\n".join(cell(f) for f in r) + "\n</tr>" for r in rows]
                      + ["</table>"])
    sections.append(f"### {artist}\n\n{table}")

block = f"{START}\n\n" + "\n\n".join(sections) + f"\n\n{END}"

readme = Path(a.readme)
text = readme.read_text() if readme.exists() else ""
if START in text and END in text:
    text = text[:text.index(START)] + block + text[text.index(END) + len(END):]
else:
    text = text.rstrip("\n") + "\n\n" + block + "\n"
readme.write_text(text)
print(f"gallery: {len(art)} pieces -> {readme}")
