package require mcecselection

mol new zundel_aligned.xyz

mcecselection -protons "3 4 5 6 7" \
    -molid 0 \
    -heavyatoms "1 2" \
    -prefix "mcec"

