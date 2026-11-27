#!/bin/bash
# pagenet-v3: synthetic data + the real training photos (x10) + MIDV ID cards.
# Then the narrower variant on exactly the same data, in the same session.
export OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1
cd ~/lipi-train/code
REAL=~/lipi-train/real-train/train.jsonl
MIDV=~/lipi-train/midv/train.jsonl
train() {   # name width epochs
  mkdir -p ~/lipi-train/runs/$1
  ~/lipi-train/venv/bin/python -m train.train \
    --train $(ls ~/lipi-train/data/train-*/train.jsonl | tr '\n' ' ') $REAL $REAL $REAL $REAL $REAL $REAL $REAL $REAL $REAL $REAL $MIDV \
    --val ~/lipi-train/data/val/val.jsonl ~/lipi-train/real-400/val.jsonl \
    --out ~/lipi-train/runs/$1 --epochs $3 --batch 128 --workers 12 --width $2 \
    > ~/lipi-train/runs/$1/train.log 2>&1
  echo TRAIN_DONE >> ~/lipi-train/runs/$1/train.log
}
train pagenet-v3 1.0 50
train pagenet-v3-narrow 0.6 50
