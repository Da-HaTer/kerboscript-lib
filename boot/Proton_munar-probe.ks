clearscreen.
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
SET TERMINAL:WIDTH      to 40. 
SET TERMINAL:HEIGHT     to 32.
set Terminal:CHARHEIGHT to 10.

function Doscience{
	toggle lights.
	wait 10.
	toggle lights.
}
function reentry{
	lock steering to retrograde .
	wait until altitude <=12500.
	unlock steering . bays on .
	wait 2.
	stage .
	wait until ship:verticalspeed < 2 .
}
if alt:radar <100{
	copypath ("0:/library/countdown.ks","").
	copypath ("0:/library/Ascent.ks","").
	copypath ("0:/library/hohman_transfer.ks","").
	copypath ("0:/library/Directions.ks","").
	copypath ("0:/library/orbit.ks","").
	list.
	wait 5.
	clearscreen.
	lock steering to up .
	lock throttle to 1.
	run countdown(11).
	run Ascent(90,75000).
}
else{// at low kerbin orbit:
	run once orbit.
	run once Directions.
	run hohman_transfer("Mun").//quotation makarks mandatory here.
	print "transfer burn successful, awaiting encounter".
	wait 3.
	print Orbit:TRANSITION.
	if Orbit:HASNEXTPATCH{//we are encountering the mun
		//warp to the next orbit.
		wait until Body:name <> "kerbin".
		set warp to 0.
		if periapsis < 10000 {
			wait until kuniverse:timewarp:issettled and warp=0. 
			lock steering to rad().
			wait 10.
			lock throttle to 0.1.
			wait until periapsis >= 10000.
			lock throttle to 0.
			set steering to retrograde . //making sure we are not going to crash on the body
		}
		else if periapsis > 20000{
			print "debug +20k".
			wait until kuniverse:timewarp:issettled and warp=0. 
			lock steering to antirad().
			wait 10.
			lock throttle to 0.1.
			wait until periapsis <= 15000.
			lock throttle to 0.
			set steering to retrograde .
		}
		wait 1.
		warpto(time:seconds+eta:periapsis).
		wait until kuniverse:timewarp:issettled and warp=0.
		print "collecting scientific observations".
		Doscience().
		//Warp to periapsis and do science.
		lock steering to retrograde .
		wait 10.
		lock throttle to 1.
		wait until orbit:eccentricity <=1.
		lock throttle to 0.
		wait 2.
		warpto(time:seconds +eta:transition).
		wait until kuniverse:timewarp:issettled and warp=0.
		wait 2.
		
	}
	print "lowering periapsis".	
	if periapsis >60000{//making sure we reenter
		warpto(time:seconds+eta:apoapsis-5).
		wait until kuniverse:timewarp:issettled and warp=0.
		lock steering to retrograde .
		wait 2.
		lock throttle to 0.1.
		wait until periapsis <=50000.
		lock throttle to 0.
		wait 1.
		//basically lowering our periapsis for aerodbraking if it's very high
	}
	warpto(time:seconds+eta:periapsis - 30).
	wait until kuniverse:timewarp:issettled and warp=0.
	stage.
	//stage #1
	reentry().
	//bracing for reentry		
}