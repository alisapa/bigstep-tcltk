#!/usr/bin/wish
# Author: Alisa Parashchenko, 2023
. configure -cursor left_ptr
set bgcol [. cget -background]
# Basic structure
frame .m -relief raised -height 1c -bd 2
frame .b -relief raised -width 2c  -bd 2
frame .c -relief flat
pack .m -side top -fill x
pack .b -side left -fill y
pack .c -fill both -expand 1
# Menus
menubutton .m.action -text Action -underline 0 -menu .m.action.menu
menubutton .m.view -text View -underline 0 -menu .m.view.menu
menu .m.action.menu
.m.action.menu add command -label "New BigStep" -accelerator "Ctrl+N" \
    -command resetCanvas
.m.action.menu add command -label "Exit" -accelerator "Ctrl+Q" -command exit
menu .m.view.menu
.m.view.menu add command -label "Font size..." -command chooseFontSize
pack .m.action .m.view -side left
tk_menuBar .m .m.action .m.view
# Buttons
button .b.tu   -text TU        -anchor s -command {insertMore Two TU}
button .b.li   -text LI        -anchor s -command {insertTwo LI}
button .b.gd   -text GD        -anchor s -command {insertTwo GD}
button .b.ld   -text LD        -anchor s -command {insertTwo LD}
button .b.app  -text APP       -anchor s -command {insertThree APP}
button .b.app' -text APP'      -anchor s -command {insertMore Three APP'}
button .b.pm   -text PM        -anchor s -command {insertTwo PM}
button .b.op   -text OP        -anchor s -command {insertThree OP}
frame  .b.nop  -height 5m
button .b.rr   -text "=>"      -anchor s -command {insertRR}
button .b.txt  -text TXT       -anchor s -command {insertTXT}
button .b.pi   -text \u03c0    -anchor s -command {insertPI}
button .b.tau  -text \u03c4    -anchor s -command {insertTAU}
frame  .b.nop2 -height 5m
button .b.insP -text ins\u03c0 -anchor s -command {insertChar \u03c0}
button .b.insT -text ins\u03c4 -anchor s -command {insertChar \u03c4}
button .b.del  -text DEL    -anchor s -command {removeMarked} -fg red
pack .b.tu .b.li .b.gd .b.ld .b.app .b.app' .b.pm .b.op .b.nop .b.rr .b.txt \
    .b.pi .b.tau .b.nop2 .b.insP .b.insT .b.del -fill x

# Building blocks
proc makeSelectable frm {
  eval $frm configure -relief raised -bd 2 -width 4m -height 4m
  bind $frm <Button-1> "markForSelection $frm"
}
proc markForSelection {widget} {
  global selection removalSelection bgcol
  if {$selection == $widget} {
    set selection {}
    $widget configure -bg $bgcol
  } else {
    if {$removalSelection != ""} {
      $removalSelection configure -bg $bgcol
      set removalSelection {}
    }
    if {$selection != ""} {
      $selection configure -bg $bgcol
    }
    set selection $widget
    $widget configure -bg blue
  }
}
proc markForRemoval {widget} {
  global selection removalSelection bgcol
  if {$removalSelection == $widget} {
    set removalSelection {}
    $widget configure -bg $bgcol
  } else {
    if {$selection != ""} {
      $selection configure -bg $bgcol
      set selection {}
    }
    if {$removalSelection != ""} {
      $removalSelection configure -bg $bgcol
    }
    set removalSelection $widget
    $widget configure -bg red
  }
}
proc frm args {
  eval frame $args
  makeSelectable [lindex $args 0]
}
proc sep args {
  eval frame $args -relief flat -height 2 -bg black
}
proc rr args {
  eval label $args -text " => " -fg blue
}
proc enlblTrace {widget name element op} {
  upvar #0 $name v
  $widget configure -width [string length $v]
}
proc replaceEnlbl {enlbl} {
# Move focus to next entry field
  set nextEnlbl [tk_focusNext $enlbl]
  if {[winfo class $nextEnlbl] == "Entry"} {
    focus $nextEnlbl
  }
# Replace current entry field with label
  label $enlbl-L -text [$enlbl get]
  pack $enlbl-L -before $enlbl -side left -anchor s
  destroy $enlbl ;# Note that $enlbl.val remains set after $enlbl is destroyed!
  bind $enlbl-L <Double-Button-1> "restoreEnlbl $enlbl"
}
proc restoreEnlbl {enlbl} {
  enlbl $enlbl
  pack $enlbl -before $enlbl-L -side left -anchor s
  destroy $enlbl-L
  $enlbl configure -width [string length [$enlbl get]]
  $enlbl icursor end
  focus $enlbl
}
proc enlbl args {
  set txtvar [lindex $args 0].val
  eval entry $args -width 1 -textvariable $txtvar
  global $txtvar ;# entry -textvariable creates a global variable
  trace variable $txtvar w "enlblTrace [lindex $args 0]"
  bind [lindex $args 0] <KeyRelease-Return> "replaceEnlbl [lindex $args 0]"
}
proc morebtn {widget name} {
  button $name -text + -width 1 -height 1 -command "addFrm $widget $name"
  set scr [format "destroy %s" $name]
  bind $name <Button-3> $scr
}

# Insertion commands
proc insertTwo {txt} {
  global selection bgcol
  if {$selection == ""} {return}
  set fr $selection
  $fr configure -bg $bgcol -relief flat -bd 2
  frame $fr.top -relief flat
  frame $fr.center -relief flat
  frame $fr.bottom -relief flat
  label $fr.center.lbl -text $txt
  frm $fr.top.1 -bg blue
  frm $fr.top.2
  sep $fr.center.sep
  enlbl $fr.bottom.l1
  rr $fr.bottom.rr
  enlbl $fr.bottom.l2
  set selection $fr.top.1
  pack $fr.top -side top -expand 1 -fill x -padx 3m
  pack $fr.center -side top -expand 1 -fill x
  pack $fr.bottom -side top -expand 1 -fill x -padx 5m
  pack $fr.top.1 -side left -padx 3m -anchor s
  pack $fr.top.2 -side left -padx 3m -anchor s
  pack $fr.center.lbl -side left
  pack $fr.center.sep -fill x -expand 1
  pack $fr.bottom.l1 $fr.bottom.rr $fr.bottom.l2 -side left -anchor n
  foreach w "$fr $fr.top $fr.center $fr.bottom $fr.center.lbl $fr.bottom.rr\
             $fr.center.sep" {
    bind $w <Button-1> "markForRemoval $fr"
  }
  focus $fr.bottom.l1
}
proc insertThree {txt} {
  global selection bgcol
  if {$selection == ""} {return}
  set fr $selection
  insertTwo $txt
  frm $fr.top.3
  pack $fr.top.3 -side left -padx 3m -anchor s
}
proc insertMore {ins txt} {
  global selection bgcol
  if {$selection == ""} {return}
  set fr $selection
  set scr [format "set %s.morecnt 1" $fr]
  uplevel #0 $scr
  insert$ins $txt
  morebtn $fr $fr.top.more
  pack $fr.top.more -side left -padx 3m -anchor s
}
proc addFrm {widget name} {
  upvar #0 $widget.morecnt cnt
  frm $widget.top.m$cnt
  pack $widget.top.m$cnt -side left -padx 3m -before $name -anchor s
  incr cnt
}
proc insertRR {} {
  global selection bgcol
  if {$selection == ""} {return}
  set fr $selection
  $fr configure -bg $bgcol -relief flat
  enlbl $fr.l1
  rr $fr.rr
  enlbl $fr.l2
  pack $fr.l1 $fr.rr $fr.l2 -side left -anchor s
  bind $fr <Button-1> "markForRemoval $fr"
  bind $fr.rr <Button-1> "markForRemoval $fr"
  focus $fr.l1
}
proc insertTXT {} {
  global selection bgcol
  if {$selection == ""} {return}
  set fr $selection
  $fr configure -bg $bgcol -relief flat
  enlbl $fr.l1
  pack $fr.l1 -anchor s
  bind $fr <Button-1> "markForRemoval $fr"
  focus $fr.l1
}
proc insertTAU {} {
  global nextTAU
  frame .c.0.tau$nextTAU
  pack .c.0.tau$nextTAU -side top -fill x -expand 1 -pady 2m
  label .c.0.tau$nextTAU.lbl -text "\u03c4$nextTAU = " -relief ridge
  enlbl .c.0.tau$nextTAU.l1
  pack .c.0.tau$nextTAU.lbl .c.0.tau$nextTAU.l1 -side left
  bind .c.0.tau$nextTAU <Button-1> "markForRemoval .c.0.tau$nextTAU"
  bind .c.0.tau$nextTAU.lbl <Button-1> "markForRemoval .c.0.tau$nextTAU"
  focus .c.0.tau$nextTAU.l1
  incr nextTAU
}
proc insertPI {} {
  global nextPI
  frame .c.0.pi$nextPI
  pack .c.0.pi$nextPI -side top -fill x -expand 1 -pady 2m
  label .c.0.pi$nextPI.lbl -text "\u03c0$nextPI = " -relief ridge
  frm .c.0.pi$nextPI.f
  pack .c.0.pi$nextPI.lbl .c.0.pi$nextPI.f -side left
  bind .c.0.pi$nextPI <Button-1> "markForRemoval .c.0.pi$nextPI"
  bind .c.0.pi$nextPI.lbl <Button-1> "markForRemoval .c.0.pi$nextPI"
  incr nextPI
}

proc insertChar {char} {
  set widget [focus -lastfor .]
  if {[winfo class $widget] != "Entry"} {return}
  $widget insert end $char
  $widget icursor end
}

proc removeMarked {} {
  global selection removalSelection bgcol
  if {$removalSelection == ""} {return}
  foreach child [winfo children $removalSelection] {
    destroy $child
  }
  foreach glbl [info globals $removalSelection.*] {
    global $glbl
    unset $glbl
  }
  if "[regexp {^.c.0.pi[0-9]*$} $removalSelection] || \
      [regexp {^.c.0.tau[0-9]*$} $removalSelection ]" {
    destroy $removalSelection
    set removalSelection {}
# $selection is already empty, no need to set that
  } else {
    set selection $removalSelection
    set removalSelection {}
    makeSelectable $selection
    $selection configure -bg blue
  }
}

proc resetCanvas {} {
  global selection nextPI nextTAU
# Destroy old frames
  foreach child [winfo children .c.0] {
    destroy $child
  }
# Forget global variables
  foreach glbl [info globals .c.0.*] {
    global $glbl
    unset $glbl
  }
# Re-create starting frame
  frm .c.0.0
  .c.0.0 configure -bg blue
  pack .c.0.0
# Reset selection and counters
  set selection .c.0.0
  set nextPI 0
  set nextTAU 0
}

proc setFontSize {} {
  global fsize
  font configure TkDefaultFont -size $fsize
  font configure TkMenuFont    -size $fsize
  font configure TkTextFont    -size $fsize
}
proc chooseFontSize {} {
  toplevel .fn
  frame .fn.frm
  pack .fn.frm
  label .fn.frm.lbl -text "Font size: "
  entry .fn.frm.ent -width 5 -textvariable fsize
  button .fn.frm.btn1 -text Apply -command setFontSize
  button .fn.frm.btn2 -text Close -command {destroy .fn}
  pack .fn.frm.lbl .fn.frm.ent -side left
  pack .fn.frm.btn1 -side top -anchor n
  pack .fn.frm.btn2 -side left
  bind .fn.frm.ent <KeyRelease-Return> setFontSize
}

bind all <Control-KeyPress-n> resetCanvas
bind all <Control-KeyPress-q> exit

frame .c.0
pack .c.0 -expand 1
frm .c.0.0
pack .c.0.0
set selection .c.0.0
.c.0.0 configure -bg blue ;# Make it actually look selected
set removalSelection {}
set nextPI 0
set nextTAU 0
set fsize [expr abs([font configure TkDefaultFont -size])]
return 0
