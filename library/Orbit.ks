//beta operations returns longitude of a given object/vessel
@lazyglobal off.
global lng is{ 
	parameter x. 
	return mod(x+360000,360).
}.
global orbitable is{
	parameter name.
	local target_if_exists is{
		if hastarget return target.
		else return false.
	}.
	local tgt is target_if_exists().
	if name= ship or name=tgt return name.
	local bodylist is list().
	list bodies in bodylist.
	for item in bodylist{
		if item:name=name return body(name).
	}
	return vessel(name).
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
    
    local t is t0+ (M-M0)/n.
    if t<0 set t to t+Per.
    return t.
}.
global an_eta is{
return anomaly_eta(360-orbit:argumentofperiapsis).
}.
global dn_eta is{
return anomaly_eta(180-orbit:argumentofperiapsis).
}.
function warp_to{
	parameter time_from_now.
	local warptime is time:seconds+time_from_now.
	warpto(warptime).
	wait 5.
	wait until kuniverse:timewarp:issettled and warp=0.  
}

//to add:
//relative an/dn
//correction vector and deltav (lossless and with loss)
//intersepting