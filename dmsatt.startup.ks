//gemini 1 startup
libreq("Directions.ks").
libreq("Science.ks").
libreq("BRIC_beta.ks").
if altitude >70000 {
	on abort{
		lock steering to retrograde .
		wait 5. lock throttle to 1.
		wait until periapsis <=60000. lock throttle to 0.
		stage.
		wait until false.
	}
	lock steering to nor()+r(0,0,45).
	run Science(2).
}
else lock steering to retrograde+r(0,-25,180).
wait 2.
reboot.