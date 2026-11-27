#!/bin/bash
# Fetches the open data for the text recognition models. No credentials are used or stored.
set -u
ROOT=$HOME/lipi-train/ocr
mkdir -p $ROOT/data/mozhi/bengali $ROOT/data/mozhi/hindi $ROOT/data/wiki $ROOT/fonts-src $ROOT/logs
cd $ROOT
echo "[$(date +%T)] pip extras"; $HOME/lipi-train/venv/bin/pip install -q pyarrow huggingface_hub fonttools scipy 2>&1 | tail -2
for lang in bengali hindi; do
  for split in train val test; do
    f=data/mozhi/$lang/$split.zip
    if [ ! -s $f ]; then echo "[$(date +%T)] mozhi $lang $split"; curl -sSL -o $f "https://ilocr.iiit.ac.in/public/printed/phase-0/v0.5/$lang/akshara/$split.zip"; fi
    (cd data/mozhi/$lang && [ -d $split ] || unzip -q -o $split.zip -d $split) 2>&1 | tail -1
  done
done
echo "[$(date +%T)] wikipedia text (CC BY-SA)"
$HOME/lipi-train/venv/bin/python - <<PY
from huggingface_hub import snapshot_download
for cfg in ["20231101.bn", "20231101.hi", "20231101.simple"]:
    try:
        p = snapshot_download(repo_id="wikimedia/wikipedia", repo_type="dataset", allow_patterns=[cfg + "/*"], local_dir="$ROOT/data/wiki")
        print("ok", cfg)
    except Exception as e:
        print("FAILED", cfg, repr(e)[:200])
PY
echo "[$(date +%T)] fonts (OFL)"
if [ ! -d fonts-src/google-fonts ]; then
  git clone -q --depth 1 --filter=blob:none --sparse https://github.com/google/fonts.git fonts-src/google-fonts
fi
cd fonts-src/google-fonts && git sparse-checkout set \
  ofl/notosansbengali ofl/notoserifbengali ofl/hindsiliguri ofl/tirobangla ofl/atma ofl/galada ofl/baloodabangla2 ofl/anekbangla ofl/mina ofl/notosansdevanagari ofl/notoserifdevanagari \
  ofl/hind ofl/mukta ofl/tirodevanagarihindi ofl/kalam ofl/yantramanav ofl/sarpanch ofl/laila ofl/amita ofl/arya ofl/khand ofl/halant ofl/rajdhani ofl/palanquin ofl/martel ofl/karma ofl/biryani \
  ofl/notosans ofl/notoserif ofl/opensans ofl/lato ofl/sourcesans3 ofl/ptserif ofl/merriweather ofl/roboto ofl/inter ofl/ibmplexsans ofl/ibmplexserif ofl/crimsontext 2>&1 | tail -1
find . -iname "*.ttf" | wc -l
echo "[$(date +%T)] done"
