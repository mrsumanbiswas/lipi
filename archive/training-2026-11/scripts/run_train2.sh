#!/bin/bash
# Synthetic data plus the real training photos (repeated 10 times so they are about a quarter of each epoch).
export OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1
cd ~/lipi-train/code
RUN=${1:-pagenet-v2}
EPOCHS=${2:-50}
mkdir -p ~/lipi-train/runs/$RUN
REAL=~/lipi-train/real-train/train.jsonl
~/lipi-train/venv/bin/python -m train.train \
  --train $(ls ~/lipi-train/data/train-*/train.jsonl | tr '\n' ' ') $REAL $REAL $REAL $REAL $REAL $REAL $REAL $REAL $REAL $REAL \
  --val ~/lipi-train/data/val/val.jsonl ~/lipi-train/real-400/val.jsonl \
  --out ~/lipi-train/runs/$RUN --epochs $EPOCHS --batch 128 --workers 12 \
  > ~/lipi-train/runs/$RUN/train.log 2>&1
echo TRAIN_DONE >> ~/lipi-train/runs/$RUN/train.log
