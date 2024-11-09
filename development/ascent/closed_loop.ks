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
function integrate{
	parameter alpha.
	parameter w.

	clearVecDraws().
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
	} // virtual trajectory integration
	return min(1,1/abs(R:mag-orbit_rad))+vdot(R0,v0). // score from 0 to 2
}

local alpha0 is 40.
local w0 is 0.1.
until dv<=0{
	local t0 is time:seconds.
	lock steering to z(w0,theta0,time:seconds-t0).
	local f0 is integrate(alpha0,w0).
	local df_dalpha is integrate(alpha0+0.1,w0)-f0.
	local df_dw is integrate(alpha0,w0+0.1)-f0.
	set alpha0 to alpha0 +df_dalpha.
	set w0 to w0+df_dw.
}
lock throttle to 0.
//todo : if it works: add yaw program

