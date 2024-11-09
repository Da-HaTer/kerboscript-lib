parameter timestep is 0.1.
clearscreen.
set config:ipu to 2000.
local T0 is time:seconds.
local f1 is ("0:/trajectoryreal01.csv"). // logz files 
local f2 is ("0:/trajectoryvirtual01.csv").
log "phi,thetha,r,t" to f1.//logs headers
log "phi,thetha,r,t" to f2. 

function integrate_trajectory{
	local dt is timestep.
	clearVecDraws().
	local R0 is -kerbin:position. //Ur0
	local v0 is ship:velocity:orbit.//V0
	//local Th0 is max(1,ship:availablethrust/ship:mass).
	//local a0 is TH0*ship:facing:vector-gacc(kerbin,R0:mag)*up:vector.
	local a0 is (-(kerbin:mass*constant:G)/(R0:mag)^2)*R0:normalized.
	
	local R is R0.
	local v is v(0,0,0).
	local a is v.

	local vtime is 0. //virtual loop time
	until (R:mag <=kerbin:radius)or(vtime>=300){
		set vtime to vtime+dt. //cumulative time 
		
		set R to R0+v0*dt.
		set v to v0+a0*dt.
		//set TH to vex/((vex/Th0)-dt).//thrust 
		set a to (-(kerbin:mass*constant:G)/(R0:mag)^2)*R:normalized.
		
		//raw vector to spherical coordinates
		local x is Body:GEOPOSITIONOF(kerbin:position+R0).   
		local phi is x:lng.
		local theta is 90-(x:lat).
		local rad is R0:mag.
		log phi+","+theta+","+rad+","+vtime to f2.
		// vecdraw(R0+kerbin:position,R-R0,red,"",1,true,0.1).
		
		set R0 to R.
		set V0 to v.
		// set TH0 to TH.
		SET a0 To a.
	}
	// virtual trajectory integration
	//return min(1,1/abs(R:mag-orbit_rad))+vdot(R0,v0). // score from 0 to 2
}
integrate_trajectory().
until false{ //crashed
	local phi is longitude.
	local theta is 90-(latitude).
	local rad is altitude.
	log phi+","+theta+","+rad+","+(time:seconds-T0) to f1.
	wait 0.1.
}

//raw vector to spherical coordinates
