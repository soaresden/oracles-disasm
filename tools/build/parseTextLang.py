#!/usr/bin/python3
# BALLADE: compiles the text of a second language (Gulls of Life: French), placed in its own banks.
#
# Runs parseText.py in a temporary folder, then renames its labels so that they don't clash with the
# first language (textTableENG -> textTable<LANG>, TEXT_OFFSET_1 -> TEXT_OFFSET_1_<LANG>, ...).
# The text indices (TX_xxxx) must be the same in both languages: this is checked here.
#
# Writes <out> (the text data) and textDefines<Lang>.s next to it (TEXT_OFFSET_SPLIT_INDEX_<LANG>).
#
# Usage: parseTextLang.py dict.yaml text.yaml out.s startAddress LANG [--EU]

import os
import re
import subprocess
import sys
import tempfile

dictFile, textFile, outFile, startAddress, lang = sys.argv[1:6]
extra = sys.argv[6:]
here = os.path.dirname(os.path.abspath(__file__))
buildDir = os.path.dirname(outFile)

with tempfile.TemporaryDirectory() as tmp:
    subprocess.run([sys.executable, os.path.join(here, 'parseText.py'), dictFile, textFile,
                    os.path.join(tmp, 'textData.s'), startAddress] + extra, check=True)
    data = open(os.path.join(tmp, 'textData.s')).read()
    defines = open(os.path.join(tmp, 'textDefines.s')).read()

# Same text indices as the first language
split = re.search(r'\.define TEXT_OFFSET_SPLIT_INDEX (\S+)', defines).group(1)
ours = defines.split('\n', 2)[2]
first = open(os.path.join(buildDir, 'textDefines.s')).read().split('\n', 2)[2]
if ours != first:
    sys.exit('parseTextLang.py: the text indices differ from the first language')

# Labels and the references to them (m_RelativePointer TX_xxxx_ADDR TEXT_OFFSET_2, ...)
data = data.replace('textTableENG', 'textTable' + lang)
data = re.sub(r'TEXT_END_(ADDR|BANK)', r'TEXT_END_\1_' + lang, data)
data = re.sub(r'\bTEXT_OFFSET_(\d)\b', r'TEXT_OFFSET_\1_' + lang, data)
data = re.sub(r'\b(?!TEXT_END)(\w+?)_ADDR\b', r'\1_' + lang + '_ADDR', data)
open(outFile, 'w').write(data)
open(os.path.join(buildDir, 'textDefines' + lang.title() + '.s'), 'w').write(
    '.define TEXT_OFFSET_SPLIT_INDEX_%s %s\n' % (lang, split))
