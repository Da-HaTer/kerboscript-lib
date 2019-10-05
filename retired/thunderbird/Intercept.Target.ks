clearscreen.
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
SET TERMINAL:WIDTH      to 45. 
SET TERMINAL:HEIGHT     to 35.
set Terminal:CHARHEIGHT to 10.
Download(startupfile).
require("orbit.ks").
require("Directions.ks").
require("Ascent.ks").
run once orbit.
run once Directions.

set target to orbitable("Desfry's Hulk").
wait until angle(target) >=250 and angle(target)<=260.
set warp to 0.
run Ascent(10,90,77000).
clearscreen.

lock relative_velocity to (target:velocity:orbit -ship:velocity:orbit):mag.
function boost{
	set tgtangle to lng(angle(ship)-angle(target)).
	set Tgt_period to tgtangle*target:obt:period/360.
	set totaldiffernce to orbit:period+Tgt_period.
	local lock difference to totaldiffernce-orbit:period.
	lock steering to prograde .
	wait 5.
	lock throttle to difference *0.01 +0.05.
	wait until obt:period >=totaldiffernce.
	lock throttle to 0.
	warp_to(eta:apoapsis).
	warp_to(eta:periapsis - 60).
}

function cancel_relative_velocity{
	wait until warp =0.
	lock steering to tgt_retro:call().
	lock throttle to (relative_velocity*0.1).
	wait until relative_velocity <= 2.
	lock throttle to 0.	
}

// cancel relative_velocity

function aproach_target{
	lock steering to tgt:call().
	wait 10.
	lock throttle to 0.5.
	wait until relative_velocity >= min(35,sqrt(target:distance)).
	lock throttle to 0.
	lock steering to tgt_retro:call().
	set distance to target:distance.
	until false{
		set prev_distance to distance.
		set distance to target:distance.
		if distance > prev_distance{
			set warp to 0.
			cancel_relative_velocity().	
			return false.
		}
		wait 0.01.
	}//we got as close as we could.
}
if not(target:distance <=25_000){
	boost().
}
rcs on.
lock steering to tgt_retro:call().
wait 10.
cancel_relative_velocity().
until target:distance <=50 and relative_velocity <=5{
	aproach_target().
}
deletepath("Ascent.ks").
print "Sucessfully reached our target".