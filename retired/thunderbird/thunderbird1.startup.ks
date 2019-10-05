//thunderbird 1 startup.ks
if hasfile("orbit.ks",1){
	run once orbit.ks.
	run once directions.ks.
	lock steering to nor().
	SET p TO SHIP:PARTSNAMED("longAntenna")[0].
	SET m to p:GETMODULE("ModuleRTAntenna").
	if altitude >70000 and angle(ship)>=270 and angle(ship)<=300{
		set warp to 0.
		wait until kuniverse:timewarp:issettled.
		wait until  addons:rt:HASCONNECTION(ship).
		if m:getfield("status")="off"{
			m:doevent("activate").
			set logsfile to ship:name+".logs.txt".
			if hasfile(logsfile,1){
				upload(logsfile).
			}
		}
	}
	else {
		if m:getfield("status")="Connected"{
			m:doevent("deactivate").
		} 
	}
}
wait 10.
reboot.