CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
SET TERMINAL:WIDTH to 52. 
SET TERMINAL:HEIGHT to 35.
clearscreen.
print shipname .
function tilt{
	parameter minalt.
	parameter angle.

	wait until alt:radar > minalt.
	lock steering to heading (90,angle).
}
lock steering to heading (90,90).
lock throttle to 1.
stage. print "liftoff".
lock throttle to 1.
stage.
until false{
	if not (defined thrust){
		set thrust to 0.
	}
	else {
		set prevthrust to thrust.
		set thrust to maxthrust .
		if thrust + 10< prevthrust {
		stage.
		wait 0.5.
		}
	}
}

tilt(5000,80).
tilt(10000,70).
tilt(15000,60).
tilt(25000,40).
tilt(30000,30).


if apoapsis > 77000 {
	lock throttle to 0.
	unlock steering .
	lock steering to prograde .
	wait until Eta:apoapsis < 50.
	lock throttle to 1.
	lock steering to heading (90,0).
	wait until periapsis > 70000.
	lock throttle to 0.
}
print "we should be in stable orbit".
wait 5.
set kuniverse:timewarp:rate to 100.
wait until longitude >= -179.
kuniverse:TimeWarp:CANCELWARP().
lock steering to retrograde .
wait until longitude >= -165.12.
stage.
//retired program