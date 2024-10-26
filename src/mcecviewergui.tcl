##
## mCEC Viewer 1.0
##
## A script to view the position of the mCEC reaction coordinate
##
## Author: Maximilian C. Poeverlein
##
## Id:
##
## Code structure based on: https://www.ks.uiuc.edu/Research/vmd/plugins/doxygen/tcltkplugins.html#tcltkplugins


package require mcecselection
package require mceccalc
package require mcecviewer

package provide mcecviewergui 1.0


namespace eval McecViewerGUI:: {
  namespace export mcecviewergui

  # window handles
  variable w                                          ;# handle to main window
}

proc McecViewerGUI::mcecviewergui {} {
    variable w

    # set some defaults
    set ::McecViewerGUI::molid 0
    set ::McecViewerGUI::rSW 1.3
    set ::McecViewerGUI::dSW 0.05
    set ::McecViewerGUI::spheresize 1
    set ::McecViewerGUI::vismaterial AOEdgy
    set ::McecViewerGUI::color blue
    set ::McecViewerGUI::outputfile "cec-trajectory.txt"
    set ::McecViewerGUI::visinputfile "cec-trajectory.txt"

    set totalwidth 65
    set labelwidth 25
    set inputwidth 40

    if { [winfo exists .mcecviewergui] } {
        wm deiconify $w
        return
    }

    set w [toplevel ".mcecviewergui"]
    wm title $w "MCEC Viewer"

    grid rowconfigure $w 0 -weight 1
    grid columnconfigure $w 0 -weight 1

    frame $w.input
    label $w.input.molidlabel       -text "MolID"                    -anchor w -width $labelwidth
    label $w.input.protonslabel     -text "Proton Indices"           -anchor w -width $labelwidth
    label $w.input.heavylabel       -text "Heavy atoms indices"      -anchor w -width $labelwidth
    label $w.input.heavycoefflabel  -text "Heavy atoms coefficients" -anchor w -width $labelwidth
    label $w.input.prefixlabel      -text "Selection prefix"         -anchor w -width $labelwidth

    entry $w.input.molid         -width $inputwidth -textvariable ::McecViewerGUI::molid
    entry $w.input.protons       -width $inputwidth -textvariable ::McecViewerGUI::protonsindices
    entry $w.input.heavys        -width $inputwidth -textvariable ::McecViewerGUI::heavyindices
    entry $w.input.heavycoeffs   -width $inputwidth -textvariable ::McecViewerGUI::heavycoeffs
    entry $w.input.prefix        -width $inputwidth -textvariable ::McecViewerGUI::selectionprefix

    grid $w.input.molidlabel       -row 1 -column 1 -columnspan 1 -sticky w 
    grid $w.input.molid            -row 1 -column 2 -columnspan 1 -sticky w 
    grid $w.input.protonslabel     -row 2 -column 1 -columnspan 1 -sticky w
    grid $w.input.protons          -row 2 -column 2 -columnspan 1 -sticky w 
    grid $w.input.heavylabel       -row 3 -column 1 -columnspan 1 -sticky w
    grid $w.input.heavys           -row 3 -column 2 -columnspan 1 -sticky w 
    grid $w.input.heavycoefflabel  -row 4 -column 1 -columnspan 1 -sticky w
    grid $w.input.heavycoeffs      -row 4 -column 2 -columnspan 1 -sticky w 
    grid $w.input.prefixlabel      -row 5 -column 1 -columnspan 1 -sticky w
    grid $w.input.prefix           -row 5 -column 2 -columnspan 1 -sticky w 

    frame $w.selectionrun
    button $w.selectionrun.button -width $totalwidth -text "Create selections" -command ::McecViewerGUI::create_selections
    grid $w.selectionrun.button -row 1 -column 1 -columnspan 1 -sticky we

    labelframe $w.mode -text "Reaction Coordinate Mode" -padx 2 -pady 4
    radiobutton $w.mode.unmodified -value "no" -variable [namespace current]::rcMode
    label $w.mode.unmodifiedlabel -text "Unmodified"

    radiobutton $w.mode.modified -value "yes" -variable [namespace current]::rcMode
    label $w.mode.modifiedlabel  -text "Modified"
    label $w.mode.modifiedlabel2 -text "Modification parameters"
    label $w.mode.modifiedlabel3 -text "Switching Distance"
    label $w.mode.modifiedlabel4 -text "Å"
    label $w.mode.modifiedlabel5 -text "Switching Width"
    label $w.mode.modifiedlabel6 -text "Å"

    entry $w.mode.rSW -width 10 -textvariable ::McecViewerGUI::rSW
    entry $w.mode.dSW -width 10 -textvariable ::McecViewerGUI::dSW

    grid $w.mode.unmodified         -row 1 -column 1 -columnspan 1 -sticky w 
    grid $w.mode.unmodifiedlabel    -row 1 -column 2 -columnspan 1 -sticky w
    grid $w.mode.modified           -row 2 -column 1 -columnspan 1 -sticky w 
    grid $w.mode.modifiedlabel      -row 2 -column 2 -columnspan 1 -sticky w
    grid $w.mode.modifiedlabel2     -row 3 -column 2 -columnspan 1 -sticky w
    grid $w.mode.modifiedlabel3     -row 4 -column 2 -columnspan 1 -sticky w
    grid $w.mode.rSW                -row 4 -column 3 -columnspan 1 -sticky w
    grid $w.mode.modifiedlabel4     -row 4 -column 4 -columnspan 1 -sticky w
    grid $w.mode.modifiedlabel5     -row 5 -column 2 -columnspan 1 -sticky w
    grid $w.mode.dSW                -row 5 -column 3 -columnspan 1 -sticky w
    grid $w.mode.modifiedlabel6     -row 5 -column 4 -columnspan 1 -sticky w

    frame $w.output
    label $w.output.outputfilelabel -text "Output file" -anchor w -width $labelwidth
    entry $w.output.outputfile -width $inputwidth -textvariable ::McecViewerGUI::outputfile

    grid $w.output.outputfilelabel  -row 1 -column 1 -columnspan 6 -sticky w 
    grid $w.output.outputfile       -row 1 -column 7 -columnspan 1 -sticky w 
    
    frame $w.run
    button $w.run.button -width $totalwidth -text "Determine mCEC" -command ::McecViewerGUI::run_mcec
    grid $w.run.button -row 1 -column 1 -columnspan 1 -sticky we

    frame $w.visualize
    label $w.visualize.inputfilelabel -text "Input file" -anchor w                -width $labelwidth
    entry $w.visualize.visinputfile   -textvariable ::McecViewerGUI::visinputfile -width $inputwidth

    grid $w.visualize.inputfilelabel  -row 1 -column 1 -columnspan 1 -sticky w 
    grid $w.visualize.visinputfile    -row 1 -column 2 -columnspan 1 -sticky w 

    frame $w.spheredesign
    label $w.spheredesign.materiallabel -text "Material"
    label $w.spheredesign.spherelabel   -text "Sphere size"
    label $w.spheredesign.colorlabel    -text "Sphere color"

    entry $w.spheredesign.vismaterial -width 10 -textvariable ::McecViewerGUI::vismaterial
    entry $w.spheredesign.sphere      -width 10 -textvariable ::McecViewerGUI::spheresize
    entry $w.spheredesign.color       -width 10 -textvariable ::McecViewerGUI::color

    grid $w.spheredesign.materiallabel   -row 2 -column 1 -columnspan 1 -sticky w
    grid $w.spheredesign.vismaterial     -row 2 -column 2 -columnspan 1 -sticky w
    grid $w.spheredesign.spherelabel     -row 2 -column 3 -columnspan 1 -sticky w
    grid $w.spheredesign.sphere          -row 2 -column 4 -columnspan 1 -sticky w
    grid $w.spheredesign.colorlabel      -row 2 -column 5 -columnspan 1 -sticky w
    grid $w.spheredesign.color           -row 2 -column 6 -columnspan 1 -sticky w

    frame $w.runvis
    button $w.runvis.button -width $totalwidth -text "Visualize mCEC" -command ::McecViewerGUI::visualize_mcec
    grid $w.runvis.button          -row 2 -column 1 -columnspan 1 -sticky we

    # global layout
    grid $w.input          -row 1 -column 1 -columnspan 1 -sticky we -padx 4 -pady 3
    grid $w.selectionrun   -row 2 -column 1 -columnspan 1 -sticky we -padx 4 -pady 3
    grid $w.mode           -row 3 -column 1 -columnspan 1 -sticky we -padx 4 -pady 3
    grid $w.output         -row 4 -column 1 -columnspan 1 -sticky we -padx 4 -pady 3
    grid $w.run            -row 5 -column 1 -columnspan 1 -sticky we -padx 4 -pady 3
    grid $w.visualize      -row 6 -column 1 -columnspan 1 -sticky we -padx 4 -pady 3
    grid $w.spheredesign   -row 7 -column 1 -columnspan 1 -sticky we -padx 4 -pady 3
    grid $w.runvis         -row 8 -column 1 -columnspan 1 -sticky we -padx 4 -pady 3

    return $w
}

proc McecViewerGUI::create_selections {} {
    set command_line {}
    append command_line [concat "-molid " $McecViewerGUI::molid " -protons \"" $McecViewerGUI::protonsindices "\" -heavyatoms \"" $McecViewerGUI::heavyindices "\" -prefix \"$McecViewerGUI::selectionprefix\""]
    eval mcecselection $command_line
    puts "Selections successfully created."
    return
}

proc McecViewerGUI::run_mcec {} {
    set command_line {}
    append command_line [concat "-molid " $McecViewerGUI::molid " -protons \"" $McecViewerGUI::protonsindices "\" -heavyatoms \"" $McecViewerGUI::heavyindices "\" -heavyweights \"$McecViewerGUI::heavycoeffs\"" " -modified" $McecViewerGUI::rcMode " -outfile" $McecViewerGUI::outputfile " -rSW" $McecViewerGUI::rSW " -dSW" $McecViewerGUI::dSW]
    eval mceccalc $command_line
    puts "CEC successfully created."
    return
}

proc McecViewerGUI::visualize_mcec {} {
    set command_line {}
    append command_line [concat "-molid" $McecViewerGUI::molid "-infile " "\"$McecViewerGUI::visinputfile\"" " -radius " $McecViewerGUI::spheresize "-material" $McecViewerGUI::vismaterial "-colorid" $McecViewerGUI::color]
    eval mcecviewer $command_line
    puts "CEC successfully visualized."
    return
}

proc mcecviewergui_tk {} {
    McecViewerGUI::mcecviewergui
    return $McecViewerGUI::w
}

