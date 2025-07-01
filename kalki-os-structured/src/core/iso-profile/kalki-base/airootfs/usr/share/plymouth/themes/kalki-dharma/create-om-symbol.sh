#!/bin/bash
convert -size 200x200 xc:transparent \
  -font /usr/share/fonts/noto/NotoSansDevanagari-Regular.ttf \
  -pointsize 100 -fill white -gravity center \
  -annotate +0+0 "ॐ" \
  "${PLYMOUTH_THEME_DIR}/om-symbol.png"
