import json
import os
import shutil
from concurrent.futures import ThreadPoolExecutor, as_completed
from collections import defaultdict
import time

SJTU_STEPS = {2, 5, 6, 8, 11, 12, 15, 17}
SRC_ROOT = r"D:\proj\grasp\frames"
DST_ROOT = r"D:\proj\grasp\sjtu_frames"
WORKERS = 16

def collect_frames():
    """Collect all SJTU frames from train and test annotations."""
    tasks = []  # list of (src_path, dst_path)
    stats = defaultdict(int)

    for split in ("train", "test"):
        path = rf"D:\proj\grasp\annotations\annotations\grasp_long-term_{split}.json"
        print(f"Loading {split} annotations...")
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)

        for ann in data["annotations"]:
            step = ann["steps"]
            if step not in SJTU_STEPS:
                continue
            img_name = ann["image_name"]  # e.g. "CASE001/00553.jpg"
            case, frame = img_name.split("/")
            
            src = os.path.join(SRC_ROOT, case, frame)
            dst_dir = os.path.join(DST_ROOT, case, f"step_{step}")
            dst = os.path.join(dst_dir, frame)
            
            tasks.append((src, dst, dst_dir))
            stats[f"{split}/{case}/step_{step}"] += 1

    print(f"\nTotal frames to copy: {len(tasks)}")
    return tasks, stats


def copy_one(args):
    src, dst, dst_dir = args
    os.makedirs(dst_dir, exist_ok=True)
    shutil.copy2(src, dst)
    return True


def main():
    tasks, stats = collect_frames()

    # Pre-create all directories to avoid race conditions
    dirs = set(t[2] for t in tasks)
    for d in dirs:
        os.makedirs(d, exist_ok=True)
    print(f"Created {len(dirs)} directories")

    print(f"Copying with {WORKERS} threads...")
    start = time.time()
    done = 0
    errors = 0

    with ThreadPoolExecutor(max_workers=WORKERS) as executor:
        futures = {executor.submit(copy_one, t): t for t in tasks}
        for future in as_completed(futures):
            try:
                future.result()
                done += 1
            except Exception as e:
                errors += 1
                src = futures[future][0]
                print(f"  ERROR: {src} -> {e}")

            if done % 5000 == 0:
                elapsed = time.time() - start
                rate = done / elapsed if elapsed > 0 else 0
                print(f"  Progress: {done}/{len(tasks)} ({rate:.0f} files/s)")

    elapsed = time.time() - start
    print(f"\nDone! Copied {done} files in {elapsed:.1f}s ({done/elapsed:.0f} files/s)")
    if errors:
        print(f"Errors: {errors}")
    print(f"Output: {DST_ROOT}")


if __name__ == "__main__":
    main()
