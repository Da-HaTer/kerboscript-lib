//MonoTask Sattlites Boot fIl
//to add : upgrade boot file.
//         remove the abort system.
clearscreen.
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
SET TERMINAL:WIDTH      to 40. 
SET TERMINAL:HEIGHT     to 32.
set Terminal:CHARHEIGHT to 10.


if alt:radar <100{
	//copypath("0:/library/orbit.ks","").
	//copypath("0:/library/hohman transfer.ks","").
	copypath ("0:/library/Ascent.ks","").
	copypath ("0:/library/Sattcom.ks","").
	runoncepath("Sattcom.ks").
	run Ascent(75000).
	activate(1).
	wait until addons:rt:HASCONNECTION(ship).
	shutdown.
}
else if periapsis >= 65000 and not addons:rt:HASCONNECTION(ship){
	toggle lights.
	lock steering to retrograde .
	wait 10.
	lock throttle to 1.
	wait until periapsis <=60000.
	lock throttle to 0.
	wait 0.1.
	stage.
}
