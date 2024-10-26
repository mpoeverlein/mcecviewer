package require mceccalc

mol new zundel_aligned.xyz waitfor all

mceccalc -protons "3 4 5 6 7" \
    -molid 0 \
    -heavyatoms "1 2" \
    -heavyweights "2 2" \
    -modified yes \
    -outfile "mcec-trajectory.txt"

exit
