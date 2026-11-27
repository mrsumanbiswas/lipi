#!/bin/bash
set -u
cd $HOME/lipi-train/ocr
git --version
# unzip with python (no unzip tool on this machine)
$HOME/lipi-train/venv/bin/python - <<PY
import zipfile, os
for lang in ("bengali", "hindi"):
    for split in ("train", "val", "test"):
        z = f"data/mozhi/{lang}/{split}.zip"; out = f"data/mozhi/{lang}/{split}"
        if os.path.isdir(out): continue
        with zipfile.ZipFile(z) as f: f.extractall(out)
        print("unzipped", lang, split, sum(len(fs) for _, _, fs in os.walk(out)), "files")
PY
rm -rf fonts-src/google-fonts; mkdir -p fonts-src/google-fonts && cd fonts-src/google-fonts
git init -q && git remote add origin https://github.com/google/fonts.git
git config core.sparseCheckout true
for d in notosansbengali notoserifbengali hindsiliguri tirobangla atma galada baloodabangla2 anekbangla mina notosansdevanagari notoserifdevanagari hind mukta tirodevanagarihindi kalam yantramanav sarpanch laila amita arya khand halant rajdhani palanquin martel karma biryani notosans notoserif opensans lato sourcesans3 ptserif merriweather roboto inter ibmplexsans ibmplexserif crimsontext; do echo "ofl/$d/" >> .git/info/sparse-checkout; done
git fetch -q --depth 1 --filter=blob:none origin main 2>&1 | tail -2
git checkout -q FETCH_HEAD 2>&1 | tail -2
echo "ttf files: $(find . -iname '*.ttf' | wc -l)"; du -sh .
echo done
