//KOStok-1 abort program.

clearscreen.
print"abort program initiated".
wait 1.
if periapsis > 65000 {
	print "orbit detecting, Deorbeting.".
	lock steering to retrograde .
	wait 7.
	lock throttle to 1.
	WAIT UNTIL PERIAPSIS < 35000 OR SHIP:LIQUIDFUEL < 0.1 OR SHIP:ELECTRICCHARGE < 5.
}

lock throttle to 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

wait 5.
print "detaching".
until false{
	stage.
}