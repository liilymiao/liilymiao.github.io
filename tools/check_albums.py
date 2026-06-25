#!/usr/bin/env python3
from collections import Counter
from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
ALBUM_DIR = ROOT / "album"
IMG_ROOT = ROOT / "assets/img/albums"
THUMB_ROOT = ROOT / "assets/thumbs/albums"


def thumb_paths(src):
    base = src.replace("/assets/img/albums/", "/assets/thumbs/albums/")
    stem = re.sub(r"\.(JPG|JPEG|jpg|jpeg)$", "", base)
    if not src.lower().endswith((".jpg", ".jpeg")):
        return []
    if src.endswith((".JPG", ".JPEG")):
        ext = Path(src).suffix
        return [f"{stem}-thumb{ext}", f"{stem}-large{ext}"]
    return [f"{stem}-thumb.jpg", f"{stem}-large.jpg"]


def collect_album_refs():
    refs = []
    srcs = []
    covers = []
    for md in sorted(ALBUM_DIR.glob("*.md")):
        text = md.read_text(errors="replace")
        rel = md.relative_to(ROOT)
        for match in re.finditer(r"^\s*-\s*src:\s*(/assets/img/albums/\S+)", text, re.M):
            srcs.append((rel, match.group(1)))
            refs.append((rel, match.group(1)))
        for match in re.finditer(r"^cover:\s*(/assets/img/albums/\S+)", text, re.M):
            covers.append((rel, match.group(1)))
            refs.append((rel, match.group(1)))
    return refs, srcs, covers


def collect_images(root):
    if not root.exists():
        return set()
    exts = {".jpg", ".jpeg", ".png"}
    return {
        "/" + str(path.relative_to(ROOT))
        for path in root.rglob("*")
        if path.is_file() and path.suffix.lower() in exts
    }


def report(title, rows):
    print(f"{title}: {len(rows)}")
    for row in rows:
        if isinstance(row, tuple):
            print("  " + " | ".join(str(part) for part in row))
        else:
            print(f"  {row}")


def main():
    refs, srcs, covers = collect_album_refs()

    missing_originals = [
        (md, src)
        for md, src in refs
        if not (ROOT / src.lstrip("/")).exists()
    ]

    missing_derivatives = []
    for md, src in refs:
        for derivative in thumb_paths(src):
            if not (ROOT / derivative.lstrip("/")).exists():
                missing_derivatives.append((md, src, derivative))

    src_counts = Counter(src for _, src in srcs)
    duplicate_srcs = [
        (src, count)
        for src, count in sorted(src_counts.items())
        if count > 1
    ]

    originals = collect_images(IMG_ROOT)
    referenced = {src for _, src in refs}
    unreferenced_originals = sorted(originals - referenced)

    expected_derivatives = set()
    for src in originals:
        expected_derivatives.update(thumb_paths(src))
    existing_derivatives = collect_images(THUMB_ROOT)
    orphan_derivatives = sorted(existing_derivatives - expected_derivatives)

    ds_store = sorted(
        path.relative_to(ROOT)
        for path in ROOT.rglob(".DS_Store")
        if ".git" not in path.parts
    )

    report("missing_originals", missing_originals)
    report("missing_thumb_or_large", missing_derivatives)
    report("duplicate_photo_sources", duplicate_srcs)
    report("orphan_thumbs", orphan_derivatives)
    report("unreferenced_originals", unreferenced_originals)
    report("ds_store_files", ds_store)

    failures = (
        missing_originals
        or missing_derivatives
        or duplicate_srcs
        or orphan_derivatives
        or ds_store
    )
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
