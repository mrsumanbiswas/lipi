# Training archive, November 2026

The trained models and logs from the November 2026 runs, which cannot be rebuilt cheaply. They were saved on 28 November 2026 because the training environment (one A100, in a container) lost GPU access and might not stay available. Source code is in `ml/`; datasets are not archived because they are public and the scripts fetch them (see `scripts/` and `models/datasets/ocr-text.md`). Paths in logs and scripts have the user name replaced by `USER`.

## Contents

| Folder | What | Notes |
|---|---|---|
| `pagenet-runs/` | Checkpoints, logs and history of the page detector runs: v1 and v2 (shipped, `models/page-net`), v3 (MIDV retrain, not shipped), v3-narrow (shipped as `page-net-small`) | `best.pt` is the checkpoint chosen on the validation sets |
| `ocr-runs/rec-s-v1/` | First text recogniser, 850,840 parameters | Has the padding flaw described in `ml/README.md`; kept as evidence, not for release. `test.json` is its batched test report |
| `ocr-runs/rec-s-v2/`, `rec-m-v2/` | Recognisers trained with the padding fix: small (850,840 parameters) and medium (1,833,744) | 60,000 steps each, about 7 hours. Validation scores only; **not yet scored on the test sets or exported** |
| `ocr-v1-export/` | ONNX and ncnn files of the v1 recogniser | Same flaw; do not ship |
| `ocr-logs/` | Training and evaluation logs | |
| `fonts.json` | Which of the 157 open fonts cover which script | |
| `scripts/` | Shell scripts that fetched the data and launched runs | They assume the old folder layout |

Each OCR run folder has `best.pt` and `last.pt` (PyTorch state, the character set and the configuration), `charset.txt` and `metrics.jsonl` (validation scores every 5,000 steps).

## Validation scores at step 60,000 (characters wrong per character; Mozhi validation words and synthetic lines, padded batches)

| Run | Bengali | Hindi | Synthetic |
|---|---|---|---|
| rec-s-v2 | 0.23% | 0.70% | 1.09% |
| rec-m-v2 | 0.19% | 0.59% | 0.99% |

These chose the checkpoint, so they are not test results. v1 read one word at a time scored far worse than in batches; the v2 models have not been checked that way yet.

## Resuming

```
python -m ocr.eval_rec --checkpoint ocr-runs/rec-m-v2/best.pt --root <data folder> --out report.json   # needs a GPU; edit the device to run on CPU
python -m ocr.export_rec --checkpoint ocr-runs/rec-m-v2/best.pt --out models/text-rec-medium/text-rec-medium
python -m ocr.check_ncnn --checkpoint ocr-runs/rec-m-v2/best.pt --prefix models/text-rec-medium/text-rec-medium --root <data folder>
```

Data layout expected by the scripts: `data/mozhi/{bengali,hindi}/{train,val,test}` (CC BY 4.0), `data/wiki/<config>/*.parquet` (Wikipedia, CC BY-SA) and `fonts-src/` (OFL fonts from the Google Fonts repository).
