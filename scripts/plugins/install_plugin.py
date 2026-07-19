#!/usr/bin/env python3
"""Install a Quickshell plugin package described by a remote manifest."""

import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import tempfile
from urllib.parse import urljoin
from urllib.request import Request, urlopen


def download(url: str) -> bytes:
    request = Request(url, headers={"User-Agent": "end4-pC-plugin-installer/1"})
    with urlopen(request, timeout=30) as response:
        return response.read()


def safe_relative_path(value: str) -> Path:
    path = PurePosixPath(value)
    if path.is_absolute() or ".." in path.parts or not path.parts:
        raise ValueError(f"unsafe package path: {value}")
    return Path(*path.parts)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest_url")
    parser.add_argument("install_root", type=Path)
    args = parser.parse_args()

    manifest_bytes = download(args.manifest_url)
    manifest = json.loads(manifest_bytes)
    plugin_id = manifest.get("id", "")
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_.-]{0,63}", plugin_id):
        raise ValueError("manifest has an invalid plugin id")

    package = manifest.get("package")
    if not isinstance(package, dict) or not isinstance(package.get("files"), list):
        raise ValueError("remote manifest must declare package.files")
    base_url = package.get("baseUrl") or args.manifest_url

    args.install_root.mkdir(parents=True, exist_ok=True)
    destination = args.install_root / plugin_id
    if destination.exists():
        raise FileExistsError(f"plugin already installed: {plugin_id}")

    staging = Path(tempfile.mkdtemp(prefix=f".{plugin_id}-", dir=args.install_root))
    try:
        (staging / "manifest.json").write_bytes(manifest_bytes)
        for entry in package["files"]:
            if isinstance(entry, str):
                relative = safe_relative_path(entry)
                url = urljoin(base_url, entry)
                expected_hash = ""
            elif isinstance(entry, dict):
                relative = safe_relative_path(entry.get("path", ""))
                url = entry.get("url") or urljoin(base_url, relative.as_posix())
                expected_hash = entry.get("sha256", "")
            else:
                raise ValueError("package.files entries must be strings or objects")

            payload = download(url)
            if expected_hash and hashlib.sha256(payload).hexdigest() != expected_hash.lower():
                raise ValueError(f"checksum mismatch for {relative}")
            target = staging / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(payload)

        os.replace(staging, destination)
    except Exception:
        shutil.rmtree(staging, ignore_errors=True)
        raise

    print(plugin_id)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
