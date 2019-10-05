clearscreen.
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
SET TERMINAL:WIDTH      to 45. 
SET TERMINAL:HEIGHT     to 35.
set Terminal:CHARHEIGHT to 10.
run once orbit.
set warp to 0.
lights on.
rcs on.
warp_to(eta:apoapsis).
lock steering to retrograde .
wait 2.
lock throttle to 1.
wait until maxthrust = 0 or periapsis <60000.
lock throttle to 0.
warp_to(eta:periapsis).
lock steering to retrograde .
m:doevent("deactivate").
stage.
shutdown.