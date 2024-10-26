#!/usr/local/bin/vmd
# visualize mCEC reaction coordinate
# Koenig et al. 2006

package provide mcecviewer 1.0

# Sphere is drawn using the following three proc's
# https://www.ks.uiuc.edu/Research/vmd/mailing_list/vmd-l/24376.html

proc enabletrace {} {
    global vmd_frame;
    trace variable vmd_frame($::McecViewer::cec_molid) w drawcounter
}

proc disabletrace {} {
    global vmd_frame;
    trace vdelete vmd_frame($::McecViewer::cec_molid) w drawcounter
}

proc drawcounter { name element op } {
    global vmd_frame;
    draw delete all
    draw color $::McecViewer::cec_colorid
    draw sphere [lindex $::McecViewer::cec_pos $vmd_frame($::McecViewer::cec_molid)] radius $::McecViewer::cec_radius resolution 16
}


namespace eval ::McecViewer:: {
    namespace export mcecviewer

    variable cec_molid
    variable cec_pos
    variable cec_radius
    variable cec_colorid
}

proc mcecviewer { args } { return [eval ::McecViewer::mcecviewer $args] }

proc ::McecViewer::mcecviewer_usage { } {
    puts "Usage: mcecviewer -molid <molid> \[opions\]"
    puts "  -infile           --  file from which cec data is loaded"
    puts "  -molid            --  molecule id to draw sphere on"
    puts "  -radius           --  cec sphere size"
    puts "  -material         --  cec sphere material"
    puts "  -colorid          --  cec sphere color name"

    error ""
}

proc ::McecViewer::mcecviewer {args} {
  global errorInfo errorCode
  # set oldcontext [psfcontext new]  ;# new context
  set errflag [catch { eval ::McecViewer::mcecviewer_core $args } errMsg]
  set savedInfo $errorInfo
  set savedCode $errorCode
  # psfcontext $oldcontext delete  ;# revert to old context
  if $errflag { error $errMsg $savedInfo $savedCode }
}

proc ::McecViewer::mcecviewer_core {args} {
    set n [llength $args]
    if {$n == 0} {mcecviewer_usage}
    # get all options
    for { set i 0 } { $i < $n } { incr i 2 } {
        set key [lindex $args $i]
        set val [lindex $args [expr $i + 1]]
        set cmdline($key) $val
    }

    set cec_infile $cmdline(-infile)
    set ::McecViewer::cec_radius $cmdline(-radius)
    set ::McecViewer::cec_colorid $cmdline(-colorid)
    set ::McecViewer::cec_molid $cmdline(-molid)
    source $cec_infile
    set ::McecViewer::cec_pos $cec_pos

    draw material $cmdline(-material)
    enabletrace

}
