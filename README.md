# GraSP — SJTU Frame Extraction Toolkit

Tools for extracting and organizing video frames assigned to **SJTU** from the [GraSP](https://github.com/JianJiangKCL/GraSP) (Granular Surgical Procedure) dataset annotations.

SJTU is responsible for annotating **8 surgical steps**: 2, 5, 6, 8, 11, 12, 15, 17.

## Prerequisites

- **Python 3.8+** (for `.py` scripts) or **PowerShell 5.1+** (for `.ps1` scripts)
- GraSP annotation files placed at:
  ```
  D:\proj\grasp\annotations\annotations\grasp_long-term_train.json
  D:\proj\grasp\annotations\annotations\grasp_long-term_test.json
  ```
- Extracted video frames at `D:\proj\grasp\frames\` with structure:
  ```
  frames/
  ├── CASE001/
  │   ├── 00001.jpg
  │   ├── 00002.jpg
  │   └── ...
  ├── CASE002/
  └── ...
  ```

## Scripts

### 1. `extract_sjtu.py` — Frame Statistics

Scans train/test annotation JSONs and prints per-case, per-step frame counts and ranges for SJTU steps.

```bash
python extract_sjtu.py
```

**Output example:**

```
=== TRAIN split ===
CASE001: 3304 frames
  step_2: 712 frames, range: CASE001/00553.jpg ~ CASE001/01024.jpg
  step_5: 736 frames, range: ...
...
Total SJTU frames in train: 20663
```

### 2. `copy_sjtu_frames.py` — Copy Frames (Python, multithreaded)

Copies all SJTU-assigned frames from `frames/` to `sjtu_frames/`, organized by case and step. Uses 16 threads for fast I/O.

```bash
python copy_sjtu_frames.py
```

**Output structure:**

```
sjtu_frames/
├── CASE001/
│   ├── step_2/
│   │   ├── 00553.jpg
│   │   └── ...
│   ├── step_5/
│   └── ...
├── CASE002/
└── ...
```

### 3. `copy_sjtu_frames.ps1` — Copy Frames (PowerShell)

Same functionality as the Python version, implemented in PowerShell.

```powershell
.\copy_sjtu_frames.ps1
```

### 4. `extract_sjtu_segments.ps1` — Generate Segment Report

Analyzes annotations and generates `sjtu_segments.md` — a detailed markdown report showing continuous frame segments per case and step. Frames with gaps > 30 are treated as separate segments.

```powershell
.\extract_sjtu_segments.ps1
```

## Reference Documents

| File | Description |
|------|-------------|
| `step.md` | Full list of 21 surgical steps with descriptions; team assignment (NUS / CUHK / SJTU) |
| `sjtu_frames.md` | Label space (instruments, actions, phases, steps) and per-case frame breakdown |
| `sjtu_segments.md` | Continuous frame segment analysis per case and step |

## SJTU Step Definitions

| Step | Name | Description |
|------|------|-------------|
| 2 | Dissection_Illiac_Lymph_Nodes | Cutting and dissection of the external iliac vein's lymph node |
| 5 | Prevessical_Dissection | Prevesical dissection |
| 6 | Ligation_Dorsal_Venous_Complex | Ligation of the dorsal venous complex |
| 8 | Seminal_Vessicle_Dissection | Seminal vesicle dissection |
| 11 | Hold_Prostate | Hold prostate |
| 12 | Pack_Prostate | Insert prostate in retrieval bag |
| 15 | Pull_Suture | Pull suture |
| 17 | Suction | Suction |

## Data Summary

| Split | Frames |
|-------|--------|
| Train (CASE001–CASE021) | 20,663 |
| Test (CASE041–CASE053) | 11,320 |
| **Total** | **31,983** |
