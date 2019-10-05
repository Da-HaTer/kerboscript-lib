CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
SET TERMINAL:WIDTH to 52. 
SET TERMINAL:HEIGHT to 35.

clearscreen.
print "hover script v1.00".
set pfactor to 0.005.
set tgalt to 500.

function ploop{
	parameter tgalt.
	parameter curralt.
	
	return (tgalt -curralt)* pfactor.
	}

set startime to time:seconds.
lock steering to up .
set autothrottle to 1.
stage.

lock throttle to autothrottle.
until ship:liquidfuel <5{
	set autothrottle to ploop(tgalt,alt:radar).
	set autothrottle to max(0,min(1,autothrottle)).
	set ourtime to time:seconds - startime.
	set error to abs(alt:radar- tgalt).

	print "time:"+ ourtime at (0,2).
	print "altitude:"+ alt:radar at (0,3).
	print "error:"+ error at (0,4).

	log (ourtime+","+alt:radar+","+error) to "0:/hoverlogs.csv".
	wait 0.05.
}
chutes on.
chutes on.
wait 2.
print "success ?!".
shutdown.
// touchdown gentle burn.