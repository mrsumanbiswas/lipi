#!/bin/bash
# Generates the synthetic splits on this machine, one process per shard.
export OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1 NUMEXPR_NUM_THREADS=1
cd ~/lipi-train/code
PY=~/lipi-train/venv/bin/python
OUT=~/lipi-train/data
rm -rf $OUT; mkdir -p $OUT
SHARDS=20; PER=1001         # 20 x 1001 = 20020 training images
for i in $(seq 0 $((SHARDS-1))); do
  $PY tools/synth.py --out $OUT/train-$i --count $PER --start $((i*PER)) --seed 1 --split train --fonts ~/lipi-train/fonts > $OUT/log-train-$i.txt 2>&1 &
done
for i in 0 1; do
  $PY tools/synth.py --out $OUT/val-$i --count 500 --start $((i*500)) --seed 2 --split val --prefix synv --fonts ~/lipi-train/fonts > $OUT/log-val-$i.txt 2>&1 &
done
wait
echo GEN_DONE > $OUT/DONE
