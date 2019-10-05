// vessel: KOStok-1
// crew Bob Kerman:
//          class: scientest
// mission: reaching polar kerbal orbit and researching science
// laucnh site: russian
clearscreen.
parameter inclination.

function tilt{
	parameter minimumalt.
	parameter angle.

    wait until alt:radar > minimumalt.
	lock steering to heading(inclination,angle).
}


Print "mission: "+shipname .
lock throttle to 1.
tilt(0, 90).
wait 2. stage.
print "Lift off!".
when MAXTHRUST=0 then {
	toggle gear.
	LOCK THROTTLE TO 0.
	stage.
	WAIT 1. 
	lock throttle to 1.
	STAGE.
}
tilt(5000, 80).
tilt(10000, 70).
toggle brakes.
tilt(20000, 55).
tilt(30000, 40).

wait until apoapsis > 80000.
lock throttle to 0.
lock steering to prograde .
toggle lights.
wait until ETA:apoapsis < 40.
lock throttle to 1.
wait until periapsis > 70000.
lock throttle to 0.

print "We have reached low kerbin orbit successfully".
print "system shutting down".
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
shutdown.
