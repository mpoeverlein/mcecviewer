package require mcecviewer

mol new zundel_aligned.xyz waitfor all

mcecviewer -molid 0 \
    -infile "mcec-trajectory.txt" \
    -radius 0.3 \
    -material "AOEdgy" \
    -colorid "blue"

