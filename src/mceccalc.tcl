#!/usr/local/bin/vmd
# calculate mCEC reaction coordinate
# Koenig et al. 2006

package provide mceccalc 1.0

namespace eval ::McecCalc:: {
    namespace export mceccalc

    # default values for modification parameters
    variable rSW 1.3
    variable dSW 0.05
}

proc mceccalc { args } { return [eval ::McecCalc::mceccalc $args] }

proc ::McecCalc::mceccalc_usage { } {
    puts "Usage: mceccalc -molid <molid> -outfile <oufile name> -modified <yes/no> \[opions\]"
    puts "  -molid            --  for which loaded molecule to determine reaction coordinate"
    puts "  -protons          --  specify proton indices (1-based)"
    puts "  -heavyatomss      --  specify heavy atom indices (1-based)"
    puts "  -heavyweights     --  specify heavy atom weights"
    puts "                        (must be same order as heavy atom indices)"
    puts "  -modified         --  whether or not to use modification term"
    puts "  -rSW              --  switching distance (Å), default: 1.3"
    puts "  -dSW              --  switching width (Å), default: 0.05"
    puts "  -outfile          --  where to save data"

    error ""
}

proc ::McecCalc::mceccalc {args} {
  global errorInfo errorCode
  # set oldcontext [psfcontext new]  ;# new context
  set errflag [catch { eval ::McecCalc::mceccalc_core $args } errMsg]
  set savedInfo $errorInfo
  set savedCode $errorCode
  # psfcontext $oldcontext delete  ;# revert to old context
  if $errflag { error $errMsg $savedInfo $savedCode }
}


proc ::McecCalc::mceccalc_core {args} {
    puts "Start reaction coordinate calculation"
    set n [llength $args]
    if {$n == 0} {mceccalc_usage}
    # get all options
    for { set i 0 } { $i < $n } { incr i 2 } {
        set key [lindex $args $i]
        set val [lindex $args [expr $i + 1]]
        set cmdline($key) $val
    }

    puts "Start reaction coordinate calculation"

    if {[info exists cmdline(-rSW)]} {
        set rSW $cmdline(-rSW)
    } else {
        set rSW 1.3
    }
    if {[info exists cmdline(-dSW)]} {
        set dSW $cmdline(-dSW)
    } else {
        set dSW 0.05
    }
    set fthresh 0.000001
    set dthresh [expr $dSW * log((1-$fthresh)/$fthresh) + $rSW]
    set use_modification $cmdline(-modified)
    set molid $cmdline(-molid)
    set outfile $cmdline(-outfile)

    set protonsinput $cmdline(-protons)
    set protons [join $protonsinput " "]
    set nprotons [llength $protons]

    set heavysinput $cmdline(-heavyatoms)
    set heavyatoms [join $heavysinput " "]
    set nheavyatoms [llength $heavyatoms]

    set heavyweightsinput $cmdline(-heavyweights)
    set heavyweights [join $heavyweightsinput " "]
    set nheavyweights [llength $heavyweights]

    set sumweights [vecsum $heavyweights]

    set mcecvector {}
    set numframes [molinfo $molid get numframes]

    for {set i 0} {$i < $numframes} {incr i} {
        set mcec [list 0 0 0]

        foreach proton $protons {
            set protonposition [lindex [[atomselect top "serial $proton" frame $i] get {x y z}] 0]
            set mcec [vecadd $mcec $protonposition]
        }

        foreach heavyatom $heavyatoms heavyatomweight $heavyweights {
            set heavyatomposition [lindex [[atomselect top "serial $heavyatom" frame $i] get {x y z}] 0]
            set mcec [vecsub $mcec [vecscale $heavyatomweight $heavyatomposition]]
        }

        puts "MCEC $mcec"

        if { $use_modification } {
            foreach proton $protons {
                foreach heavyatom $heavyatoms {
                    set p [lindex [[atomselect top "serial $proton" frame $i] get {x y z}] 0]
                    set h [lindex [[atomselect top "serial $heavyatom" frame $i] get {x y z}] 0]
                    set d [vecdist $p $h]
                    set ph [vecsub $p $h]
                    if { $d > $dthresh } { continue }
                    set f [expr 1 / (1 + exp(($d-$rSW)/$dSW))]
        	        puts $f
        	        puts [vecscale $f $ph]
                    if { $f < $fthresh } { continue }
                    set mcec [vecsub $mcec [vecscale $f $ph]]
            	    puts $mcec
                }
            }
        }
        puts [llength $mcec]
        puts "mCEC $mcec"
        puts [llength $mcecvector]
        
        lappend mcecvector $mcec
    }


    # write mcec to outfile as a tcl script
    set fp [open $outfile w]
    puts $fp "set cec_pos \{"
    puts $fp $mcecvector
    puts $fp "\}"


    return
}
