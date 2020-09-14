//ascent trajectory
function GVEC{
    parameter vec.//vector end
    parameter name is "N/A".
    parameter color is rgb(random()*3,random()*3,random()*3).
    return vecdraw(
        v(0,0,0),
        vec,
        color,
        name,
        10,
        true,
        0.01
    ).
} //dra


//second equation:
//set pitch to 90*e^(5/(targetaltitude+20_000)*-altitude).
//thrid equation:
//setg pitch to max(0,100*constant:e^(x/25000).

set azimuth to 90.
set locup to heading(azimuth,0):vector*-1.

set targetaltitude to 75000.
set tgtw to sqrt(kerbin:mass*constant:g/(targetaltitude+600_000)). //final vctor
lock vecpitch to min(90,100*0.1^(altitude /100_000)).

when altitude >=40_000 then lock tgtvec to heading(azimuth,vecpitch-10):vector.
lock tgtvec to heading(azimuth,vecpitch):vector-srfprograde:vector*tan(0.5).// fixvec at launch
//lock fixvec to tgtvec+(log10(altitude))*(tgtvec-ship:srfprograde:vector).
lock fixvec to (tgtvec*(tgtw*1.2)-ship:prograde:vector*ship:velocity:orbit:mag):normalized. 
stage.
lock throttle to 1.
wait 7.
stage.
lock steering to lookdirup(tgtvec,locup).
wait until verticalspeed >20.
wait until vang(fixvec,ship:srfprograde:vector) <3.
lock steering to lookdirup(fixvec,locup).
set v1 to GVEC(ship:srfprograde:vector,"prograde").
set v1:vecupdater to {return ship:srfprograde:vector.}.

set v2 to GVEC(tgtvec,"target").
set v2:vecupdater to {return tgtvec.}.

set v3 to GVEC(fixvec,"fix").
set v3:vecupdater to {return fixvec.}.

wait until apoapsis >= targetaltitude.
lock throttle to 0.
local orbit_velocity is tgtw*velocityat(ship,time:seconds+eta:apoapsis):orbit:normalized.
local apoapsis_velocity is velocityat(ship,time:seconds+eta:apoapsis):orbit.
local circularize_dv is orbit_velocity:mag- apoapsis_velocity:mag.// deltav needed to circularize / may be in accurate assuming gravity loss
lock steering to lookdirup(orbit_velocity,kerbin:position). //maneuver node
local Bt is 9.81*ship:mass*345*(1-constant:E^(-circularize_dv/(9.81*345)))/availablethrust.
warpto(time:seconds+eta:apoapsis-Bt).
wait until Bt/2>eta:apoapsis.
    lock throttle to 1.
    //wait until ship:velocity:orbit:mag >= orbit_velocity:mag. // will generally overshoot (not a problem)
    wait bt.
    Lock throttle to 0.
    set runmode to 0.


//target intercept 

clearvecdraws().
function GVEC{
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
        0.1
    ).
} //dra


lock relative_velocity to target:velocity:orbit -ship:velocity:orbit.
lock q to min(50,sqrt(target:position:mag))/5.
lock trgt_vec to target:position:normalized*q.
lock diffvec to trgt_vec+relative_velocity.
lock steering to target:position.
set v1 to GVEC(trgt_vec,"target").
set v1:vecupdater to {return trgt_vec.}.

set v2 to GVEC(-relative_velocity,"relative_velocity").
set v2:vecupdater to {return -relative_velocity.}.

function follow{
    parameter tgt_vec.
    local foreval is vdot(tgt_vec,ship:facing:forevector).
    local starval is vdot(tgt_vec,ship:facing:starvector).
    local topval is vdot(tgt_vec,ship:facing:topvector).
    local k is 0.2.
    set ship:control:fore to foreval*k.
    set ship:control:starboard to starval*k.
    set ship:control:top to topval*k.
}
until false{
    follow(diffvec).
    print "relative vel "+ relative_velocity:mag at (0,9).
    wait 0.1.
}

clearscreen.
set i to 1.
set lst_stg to 0.
for p in ship:parts{
    
    set stg to p:stage.
    if stg <> lst_stg{
        set lst_stg to stg.
        set i to i+1.
    }
    print stg at (27,i).
    print p:name at (0,i).
    print "|" at (25,i).
    set i to i+1. 
}