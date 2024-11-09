//open loop pitch program

//unit thrust vector

//1 wait until aligned with prograde then pitch gradually.

//2


local j is up:vector.
local i is heading(90,0):vector.

wait until vang(heading(90,90):vector,srfprograde:vector)<=2.
//parameters
local t0 is time:seconds.
local w is 0.4. //deg /s >> 1 deg every 5 seconds >> 45 degrees in 225 seconds
local theta is 90.
lock trajectory to cos(-w*(time:seconds-t0)+theta)*i+sin(-w*(time:seconds-t0)+theta)*j.
lock steering to trajectory.
set v2 to GVEC(trajectory,"aim").
set v2:vecupdater to {return trajectory*20.}.

wait until stage:number<=2.

runpath("closed_loop.ks").
// works fine so far