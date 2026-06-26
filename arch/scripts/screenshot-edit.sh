#!/bin/bash
# Region screenshot into swappy editor (annotate, copy or save).
geom=$(slurp) || exit 0          # ESC / cancel -> do nothing
grim -g "$geom" - | swappy -f -
