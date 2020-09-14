SET V0 to GetVoice(0).
SET V0:VOLUME TO 1.
SET V0:WAVE to "square".
SET V0:ATTACK to 0.2.
SET V0:DECAY to 0.1.
SET V0:SUSTAIN to 0.3. // 70% volume while sustaining.
SET V0:RELEASE to 0.2. // takes half a second to fade out.

function going2crush{
	if verticalspeed <=-50 or (alt:radar <= 100 and verticalspeed <10 and airspeed >= 120) return true.
	return false.
}
when true then {
	v0:play(note(400,1)).
	HUDTEXT( "PULL UP!",
		 0.6,
		 6,
		 50,
		 rgba(1,0.5,0.5,0.5),
		 false).
	wait 0.5.
	preserve.
}
wait until false.

	function ish{
		parameter a.
		parameter b.
		parameter ishyness.
		return a+ishyness>b and a- ishyness <b.
	 }


function azimuth{
	parameter az_inc.
	set negative to false.
	local orbvel is 2250.
	local rotvel is body:angularvel:mag*body:radius*cos(latitude).
	local negative is false.
	if az_inc<0 set negative to true.
    set az_inc to abs(az_inc).
    local  a is arctan((sin(az_inc)*orbvel)/(cos(az_inc)*orbvel-rotvel)).
    if a<0 {
        set a to a+180.
    }
    if negative set a to -a.
    return a.
}
set target to vessel("Kerbal X").
function launch_window{
	parameter tgt_inc is false.
	parameter tgt_lan is false.
	function lng{ //calculates angles in better range
		parameter x. // longitude / latitude
		return mod(x+3600,360).
	}
	if hasTarget{
		set tgt_inc to target:obt:inclination.
		set tgt_lan to lng(target:obt:lan).
	}
	local X is arcsin(tan(latitude)/tan(tgt_inc)).
	local asc is lng(tgt_lan+X).
	local dsc is lng(tgt_lan+180-X).
	if latitude <0 {
		set asc to lng(asc-2*X).
		set dsc to lng(asc+2*X).
	}
	if lng(asc-longitude-body:rotationAngle)<lng(dsc-longitude-body:rotationangle){
		global ASC is true.
		return lng(asc-longitude-body:rotationAngle)/(body:angularvel:mag*constant:radtodeg).
	}
	else {
		global ASC is false.
		return lng(dsc-longitude-body:rotationangle)/(body:angularvel:mag*constant:radtodeg).
	}
	
}	
warpto(time:seconds+launch_window()-120).//- ascent time
local lock inc to azimuth(90-arcsin(cos(target:obt:inclination)/cos(latitude))).
local q is 1.
if not ASC set q to -1.
lock steering to heading((90-inc*q),90*0.1^((apoapsis +altitude )/2 /70_000)).

wait until apoapsis >70000.

///////////////////////
libreq("orbit.ks").
runoncepath("0:/orbit.ks").
local orb1 is ship:obt.
local orb2 is target:obt.

local lan1 is orb1:lan.
local inc1 is orb1:inclination.

local lan2 is orb2:lan.
local inc2 is orb2:inclination.

local AP is orb1:argumentofperiapsis.
local e is orb1:Eccentricity.
//orbital elements

local relative_inclination is vang(angular_vel(lan1,inc1),angular_vel(lan2,inc2)).

local Y is SIN(180-inc2)*sin(lan2-lan1)/sin(relative_inclination).
local X is (cos(180-inc2)+cos(inc1)*cos(relative_inclination))/(sin(inc1)*sin(relative_inclination)).
local Ea is arctan2(y,x).
//local relative_an_epoch is time:seconds+anomaly_eta(180+Ea-Ap).
local relative_dn_epoch is time:seconds+anomaly_eta(Ea-Ap).
local relative_an_epoch is time:seconds+anomaly_eta(180+Ea-Ap).
if relative_dn_epoch < relative_an_epoch{
local v is velocityat(ship,relative_dn_epoch):orbit:mag.
add node(relative_dn_epoch,0,sin(relative_inclination)*v,-v*(1-cos(relative_inclination))).}
else {
	local v is velocityat(ship,relative_an_epoch):orbit:mag.
	add node(relative_an_epoch,0,-sin(relative_inclination)*v,-v*(1-cos(relative_inclination))).


function lng {
	parameter angle.
	return mod(angle+3600,360).
}
function period{
	parameter a.
	return 2*constant:pi*sqrt(a^3/(Kerbin:mass*constant:G)).
}

function dv1{
	parameter a1.
	parameter a2.
	return sqrt(Kerbin:mass*constant:g/a1)*(sqrt(2*a2/(a1+a2))-1).
}
function dv2{
	parameter a1.
	parameter a2.
	return sqrt(Kerbin:mass*constant:g/a2)*(1-sqrt(2*a1/(a1+a2))).	
}

local dh is 25_000.
local halt_angle is 45.

local a3 is target:obt:semimajoraxis.
local a2 is target:obt:semimajoraxis-dh.
local a1 is orbit:semimajoraxis.

local w3 is 360/period(a3).
local w2 is 360/period(a2).
local w1 is 360/period(a1).


//local p4 is 0.
local Tp4 is period(a3-dh/2)/2.
local tp3 is halt_angle/w2.
local tp2 is period((a2+a1)/2)/2.

local Dp is lng(halt_angle-w3*(tp4+tp3+tp2)).
print "dp "+dp.
local x is lng(target:obt:trueanomaly+target:obt:argumentofperiapsis-orbit:trueanomaly-orbit:argumentofperiapsis).
print x.
local tp1 is (lng(x-dp))/(w1-w3).
print "tp1 "+tp1.

local t1 is time:seconds+tp1.
local t2 is t1+tp2.
local t3 is t2+tp3.
local t4 is t3+tp4.
add node(t1,0,0,dv1(a1,a2)).
add node(t2,0,0,dv2(a1,a2)).
add node(t3,0,0,dv1(a2,a3)).
add node(t4,0,0,dv2(a2,a3)).


global trueanomaly is {
	parameter Ec.
	parameter e is orbit:Eccentricity.
    return arctan2(sqrt(1-e^2)*sin(Ec),(cos(Ec)-e)).
}.

global Eccentricanomaly is{
	parameter T is orbit:trueanomaly.
	parameter e is orbit:Eccentricity.
    return arctan2(sqrt(1-e^2)*sin(T),(cos(T)+e)).
}.
global Meananomaly is {
	parameter En is Eccentricanomaly().
	parameter e is orbit:Eccentricity.
	return (constant:degtorad*En-e*sin(En))*constant:radtodeg.
}.
global Eccentricanomaly2 is{
	parameter M is Meananomaly().
	parameter e is e.
	set M TO M*constant:degtorad.
	local x is 0.
	local step_ is 1.
	local last_error is abs(M-constant:degtorad*x+e*sin(x)).
	local error is 0.
	until abs(step_)<1e-6{
		set x to x+step_.
	    set error to abs(M-constant:degtorad*x+e*sin(x)).
	    if last_error < error set step_ to -step_/5.
	    set last_error to error.
	}
	return x.
}.
global anomaly_eta is{
    parameter trueanomaly.
    local t0 is 0.
    local n is sqrt(kerbin:mass*constant:g/orbit:semimajoraxis^3).
    //local n is 360/orbit:period.
    local ecc is orbit:Eccentricity.
    local v0 is orbit:trueanomaly.
    local v is trueanomaly.
    local Per is orbit:period.
    
    local E0 is arctan2(sqrt(1-ecc^2)*sin(v0),ecc+cos(v0)).
    local E is arctan2(sqrt(1-ecc^2)*sin(v),ecc+cos(v)).
    local M0 is (constant:degtorad*E0-ecc *sin(E0)).
    local M is (constant:degtorad*E-ecc*sin(E)).
    
    local t is t0+(M-M0)/n.
    if t<0 set t to t+Per.
    return t.
}.
function lng {
	parameter angle.
	return mod(angle+3600,360).
}
function period{
	parameter a.
	return 2*constant:pi*sqrt(a^3/(Kerbin:mass*constant:G)).
}

function dv1{
	parameter a1.
	parameter a2.
	return sqrt(Kerbin:mass*constant:g/a1)*(sqrt(2*a2/(a1+a2))-1).
}
function dv2{
	parameter a1.
	parameter a2.
	return sqrt(Kerbin:mass*constant:g/a2)*(1-sqrt(2*a1/(a1+a2))).	
}
local a1 is orbit:semimajoraxis.
local a2 is target:obt:semimajoraxis.
local a4 is (a1+a2*(1+target:obt:Eccentricity))/2.
local TP1 is period(a4)/2.
local TP2 is anomaly_eta(target:obt:argumentofperiapsis-orbit:argumentofperiapsis).

local n is sqrt(Kerbin:mass*constant:G/a2^3).

local M0 is Meananomaly().
//local M3 is Meananomaly(180).
local M2 is 180-n*TP1.
local M1 is M0+n*TP2.

local TP3 is (M2-M1)/n.
if floor(TP3/period(a1))=0{
	set TP3 to TP3+period(a3).
}
local no is floor(TP3/period(a1)).
local rs is mod(TP3,period(a1)).
local a3 is ((period(a1)+rs/no)^2/4/constant:pi^2*constant:G*kerbin:mass)^(1/3).


//add node(time:seconds+TP2,0,0,dv1(a1,(a3+a1)/2)).
add node(time:seconds+1000,0,0,dv1(a1,a4)).
//add node(time:seconds+TP2+TP3+TP1,0,0,dv2(a4,a2)).

