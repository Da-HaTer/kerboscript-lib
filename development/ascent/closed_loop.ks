//closed loop guidance

//parameters
clearscreen.
local dt is 1. //time step
set config:ipu to 2000.
//constants
 //changeme



//desired parameters:
local orbit_rad is 75000+ 600_000.
local orbital_vel is sqrt(mu()/(orbit_rad)).

function mu{
	parameter bod is body.
	return constant:G*bod:mass.
}
function gacc{
	parameter bod is body.
	parameter height is 600_000.
	return mu(bod)/(height )^2.
}
global G0 is gacc(kerbin).
local myengines is list().
list engines in myengines.
function activeISP{
	return max(ISP(1),50).
}
function totalISP{
	return isp().
}
function ISP{
	parameter active is 0.
	local totalfactor is 0.
	local totisp is 0.
	for eng in myengines{
		local condition is (not eng:flameout).
		if active<>0 set condition to condition and eng:ignition.
		if condition{
			set totalfactor to totalfactor +1.
			set totisp to totisp + eng:vacuumisp.
		}
	}
	if totalfactor <>0 return totisp/totalfactor. //gets average isp of the active engines.
	return 0.
}

global burntime is{
    parameter dv.
    local F is availablethrust .
    local isp is activeISP().
    if F<>0 return G0*ship:mass*isp*(1-constant:E^(-dv/(G0*isp)))/F.
    else return 60.
}.
 	 
local vex is 9.81*isp*activeISP().
//heading vector
function z{
		parameter w.
		parameter theta0.
		parameter t.
		local i is heading(90,0):vector.
		local j is up:vector.
		local theta is -w*(t)+theta0. //aoa as a function of time
		return cos(theta)*i+sin(theta)*j.
		
	}


local theta0 is 90-vang(ship:facing:vector,up:vector). // angle of attack
local lock dv to orbital_vel-ship:velocity:orbit:mag.
local lock TGO to burntime(dv).// burntime function
local w is 0.5.

local last_score is 0.

local overshot is false.
lock impossible to theta0>90.
until (dv<=0 ){ //edit me or impossible
	if overshot set theta0 to max(-10,theta0-0.2).
	else set theta0 to min(45,theta0+0.2).
	print "angle: "+theta0 at (0,5).
	local t0 is time:seconds.
	lock steering to z(w,theta0,time:seconds-t0)..
	clearVecDraws().
	
	//initial states of vehicle
	local R0 is -kerbin:position.
	local v0 is ship:velocity:orbit.
	local Th0 is max(1,ship:availablethrust/ship:mass).
	local a0 is TH0*ship:facing:vector-gacc(kerbin,R0:mag)*up:vector.
	local v is v(0,0,0).
	local vtime is 0. //virtual loop time
	until V:mag >=orbital_vel{
		set vtime to vtime+dt. //cumulative time 
		set R to R0+v0*dt.
		set v to v0+a0*dt.
		set TH to vex/((vex/Th0)-dt).//thrust 
		set a to TH*z(w,theta0,vtime)-gacc(kerbin,R:mag)*R:normalized.
		print "radius:  "+R:mag at (0,6).
		print "velocity: "+V:mag at (0,7).
		vecdraw(R0+kerbin:position,R-R0,red,"",1,true,0.1).
		set R0 to R.
		set V0 to v.
		set TH0 to TH.
		SET a0 To a.
	}//big interation (make a function somehow and aproximate maybe)
	set penalty to 1/abs(R0:mag-orbit_rad).
	print "TGO: "+vtime at (0,8).
	set overshot to R0:mag>orbit_rad.
	set w to theta0/(1.5*vtime).
}
lock throttle to 0.

//todo : if it works: add yaw program



set score to min(1,1/R)+vdot(R0,v0). // max score is 2.

