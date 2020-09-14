//ascent v1: gravity turn
local turntime is 30.

clearscreen.
local vessel_height is alt:radar.

clearvecdraws().
global GVEC is{
    parameter vec.//vector end
    parameter name is "N/A".
    parameter color is rgb(random()*3,random()*3,random()*3).
    return vecdraw(
        v(0,0,0),
        vec,
        color,
        name,
        1,
        true,
        0.5
    ).
}. //dra



function releaseclamps{
    local clamps is list().
    for p in ship:parts{
        if p:name = "launchclamp1" clamps:add(p).
    }
    for p in clamps{
        local m is p:getmodule("launchclamp").
        m:doevent("release clamp").
	}
}

function throttleup{
	parameter timer.
	local t0 is time:seconds.
	lock throttle to 1/timer*(time:seconds-t0).
	wait until throttle >=1.
	lock throttle to 1.
}


//1-wait until clear of launch site
stage.
print "egnition".
throttleup(2).
releaseclamps().
print "liftoff".
lock steering to lookdirup(up:vector,ship:facing:topvector).
wait until alt:radar > 3*vessel_height.
local i is ship:facing:topvector.
local j is heading(90,0):vector. //change to parameter azimuth
local k is vcrs(i,vcrs(i,j)).
local w is vang(i,j)/turntime.
local t0 is time:seconds.
print "gravity turn".
lock steering to lookdirup(up:vector,cos(w*(time:seconds-t0))*i+sin(w*(time:seconds-t0))*k).
wait until time:seconds>t0+turntime.
lock steering to heading(90,90).
wait 1.
runpath("open_loop.ks").