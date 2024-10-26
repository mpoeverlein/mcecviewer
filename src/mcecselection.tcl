#!/usr/local/bin/vmd
# create selections for mCEC reaction coordinate
# Koenig et al. 2006

package provide mcecselection 1.0


namespace eval ::McecSelection:: {
    namespace export mcecselection
}

proc mcecselection { args } { return [eval ::McecSelection::mcecselection $args] }

proc ::McecSelection::mcecselection_usage { } {
    puts "Usage: mcecselection -molid <molid> \[opions\]"
    puts "  -molid            --  for which loaded molecule to determine reaction coordinate"
    puts "  -protons          --  specify proton indices (1-based)"
    puts "  -heavyatoms       --  specify heavy atom indices (1-based)"
    puts "  -prefix           --  prefix for macro names (default: mcec_)"

    error ""
}

proc ::McecSelection::mcecselection {args} {
  global errorInfo errorCode
  # set oldcontext [psfcontext new]  ;# new context
  set errflag [catch { eval ::McecSelection::mcecselection_core $args } errMsg]
  set savedInfo $errorInfo
  set savedCode $errorCode
  # psfcontext $oldcontext delete  ;# revert to old context
  if $errflag { error $errMsg $savedInfo $savedCode }
}

proc ::McecSelection::mcecselection_core {args} {
    set n [llength $args]
    if {$n == 0} {mcecselection_usage}
    # get all options
    for { set i 0 } { $i < $n } { incr i 2 } {
        set key [lindex $args $i]
        set val [lindex $args [expr $i + 1]]
        set cmdline($key) $val
    }

    set molid $cmdline(-molid)
    set protonsinput $cmdline(-protons)
    set heavysinput $cmdline(-heavyatoms)
    set prefix $cmdline(-prefix)

    atomselect macro ${prefix}_protons "serial $protonsinput"
    atomselect macro ${prefix}_heavy_atoms "serial $heavysinput"


    mol selection "${prefix}_protons"
    mol representation {CPK 1.0 0}
    mol Material Glossy
    mol addrep $molid

    mol selection "${prefix}_heavy_atoms"
    mol representation {CPK 1.0 0}
    mol Material Glossy
    mol addrep $molid

    mol selection "${prefix}_heavy_atoms or ${prefix}_protons"
    mol representation {DynamicBonds 1.3 0.1}
    mol Material Glossy
    mol addrep $molid

}

