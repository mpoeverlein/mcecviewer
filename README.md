# mcecviewer
A VMD plugin to visualize the (modified) center of excess charge reaction coordinate in a trajectory

## Installation
1. clone this repository to a directory of your choice
2. Add the following lines to your `.vmdrc` file:
    lappend autopath <path>/mcecviewer/src
    source <path>/mcecviewer/src/mceccalc.tcl
    source <path>/mcecviewer/src/mcecselection.tcl
    source <path>/mcecviewer/src/mcecviewer.tcl
    source <path>/mcecviewer/src/mcecviewergui.tcl

    vmd_install_extension mcecviewergui mcecviewergui_tk "Visualization/MCEC Viewer"
3. Start VMD. The plugin is accessible under `Extensions > Visualization > MCEC Viewer"

## Manual
Coming soon.
