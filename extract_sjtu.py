import json
from collections import defaultdict

sjtu_steps = {2, 5, 6, 8, 11, 12, 15, 17}

for split_name, path in [('train', r'D:\proj\grasp\annotations\annotations\grasp_long-term_train.json'), ('test', r'D:\proj\grasp\annotations\annotations\grasp_long-term_test.json')]:
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    case_step_frames = defaultdict(lambda: defaultdict(list))
    total = 0
    
    for ann in data['annotations']:
        step = ann['steps']
        if step in sjtu_steps:
            fname = ann['image_name']
            case = fname.split('/')[0]
            case_step_frames[case][step].append(fname)
            total += 1
    
    print(f'=== {split_name.upper()} split ===')
    for case in sorted(case_step_frames.keys()):
        steps = case_step_frames[case]
        case_total = sum(len(v) for v in steps.values())
        print(f'{case}: {case_total} frames')
        for s in sorted(steps.keys()):
            frames = steps[s]
            print(f'  step_{s}: {len(frames)} frames, range: {frames[0]} ~ {frames[-1]}')
    print(f'Total SJTU frames in {split_name}: {total}')
    print()
