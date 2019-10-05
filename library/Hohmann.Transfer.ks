parameter abt is 0. //angle behind target
parameter tgt is target. //target
parameter r2 is tgt:obt:semimajoraxis.

//libreq("Orbit.ks").
//libreq("BRIC_beta.ks").
runoncepath("0:/library/orbit.ks").
runoncepath("0:/library/bric_beta.ks").
clearscreen.
set throttctl to{
    parameter a.
    parameter b.
    set p to floor(log10(max(a,b))).
    set d to abs(floor(a-b))*10^(-p).
    print "power "+p at(0,15).
    print "output "+(d+0.01) at (0,16).
    return d+0.01.
}.
local lock r1 to ship:obt:semimajoraxis.
local u is mu().
LOCAL dv1 is sqrt(u/r1)*(sqrt(2*r2/(r1+r2))-1).// delta v of first burn
//set dv2 to sqrt(u/r2)*(1-sqrt(2*r1/(r2+r1))).// delta v of first burn
if r1<r2 lock steering to prograde.
else lock steering to retrograde.
wait 5.
//general variables (work both with target and without)
if hastarget {
    if tgt =target{
        local hohmandifference is lng(constant:radtodeg*constant:pi*(1-1/(2*sqrt(2))*sqrt(((r1/r2)+1)^3))+abt). 
        //phase angle
        local lock difference to abs(lng(angle(tgt)-angle(ship))-hohmandifference). //real angle
        set t1 to burntime(dv1).
        if difference >15{
            set warp to 3.
        }
        wait until difference <=t1*360/ship:obt:period+10.
        set warp to 1.
        wait until difference <= t1*360/ship:obt:period+1.
        set warp to 0.
        wait until difference <= t1*360/ship:obt:period.
    }
}

//lock throttle to throttctl(r2,apoapsis +600000). // 1e-5 thro control
if r1 <r2 local lock extremum to apoapsis.
else local lock extremum to periapsis. 
lock throttle to throttctl(extremum+600000,r2).
if r1 <r2 wait until extremum >=r2-600000.
else wait until extremum <=r2-600000.
lock throttle to 0.