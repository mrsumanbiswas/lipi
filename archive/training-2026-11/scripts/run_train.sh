#!/bin/bash
# Trains PageNet on the uploaded synthetic data, validating on synthetic and real validation sets.
export OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1
cd ~/lipi-train/code
RUN=${1:-pagenet-v1}
EPOCHS=${2:-60}
mkdir -p ~/lipi-train/runs/$RUN
~/lipi-train/venv/bin/python -m train.train \
  --train $(ls ~/lipi-train/data/train-*/train.jsonl | tr '\n' ' ') \
  --val ~/lipi-train/data/val/val.jsonl ~/lipi-train/real-400/val.jsonl \
  --out ~/lipi-train/runs/$RUN --epochs $EPOCHS --batch 128 --workers 12 \
  > ~/lipi-train/runs/$RUN/train.log 2>&1
echo TRAIN_DONE >> ~/lipi-train/runs/$RUN/train.log
