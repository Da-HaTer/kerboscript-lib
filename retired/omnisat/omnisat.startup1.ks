libreq("Orbit.ks").
libreq("Sattcom.ks").
libreq("Directions.ks").
if altitude >70000 {
	lock steering to nor().
	if angle(ship)>=260 and angle(ship)<=310{ //function to better determine range in koslib.
		set warp to 0.
		wait until kuniverse:timewarp:issettled.
		activate(5).
	}
	else {
		deactivate(5).
	}
}
wait 10.
reboot.