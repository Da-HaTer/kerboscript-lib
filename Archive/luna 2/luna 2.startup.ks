//launch window 
clearscreen.
print "startup".
wait 1.
//runoncepath("0:/library/orbit.ks").
//copypath("0:/library/kos.lib.ks","").

function writemode{
    parameter runmode.
    local drive is "drive.ks".
    log "" to drive.
    deletepath("1:/"+drive).
    log "set runmode to "+runmode+"." to drive.
}
function readmode{
    local drive is "drive.ks".
    log "" to drive.
    runpath("1:/"+drive).
}
set runmode to 0.
readmode().
when maxthrust =0 and runmode<>0 then{
    if stage:number >2 {
        rcs on.
        stage.
        wait 1.
        rcs off.
    }
    else rcs on.
    local rcslist is list().
    for part_ in ship:parts{
        if part_:hasmodule("modulercsfx") rcslist:add(part_).
    }
    for part_ in rcslist{
        local m is part_:getmodule("modulercsfx").
        if m:hasevent("hide actuation toggles") m:doevent("hide actuation toggles").
        if m:allevents[0]="(callable) show actuation toggles, is kspevent"{
            m:doevent("show actuation toggles").
            m:setfield("fore by throttle",true).
        }
    }
    preserve.
}
print "runmode: "+runmode at (0,5).
if runmode=0{
    //launch
    runoncepath("1:/orbit.ks").
    set Tf_p to constant:pi*sqrt(((75_000+mun:altitude+1_200_000)/2)^3/(kerbin:mass* constant:G)).
    //transfer period = 2pi sqrt(a^3/µ)
    set mw to mun:velocity:orbit:mag/mun:altitude.
    //angular velocity of the moon in radiants
    set Dph to mw*constant:radtodeg*Tf_p.
    //deltaphase
    set rmw to (kerbin:angularvel:mag-mw)*constant:radtodeg.

    //relative angular velocity
    set t to lng(mun:longitude-longitude -270+Dph)/rmw.
    warp_to(t-11).
    runpath("0:/library/ascent.ks",75_000,10).
    writemode(1).
    reboot.
}
if runmode=1{
    runoncepath("1:/orbit.ks").
    add node(time:seconds+min(an_eta(),dn_eta()),0,0,0).
    set startime to time:seconds.
    set t to nextnode:eta.
    remove nextnode.
    local dltav is 800.
    local last_diff is 1e8.
    local step_ is 1.
    local hadpatch is false.
    set tgt to 100.
    until abs(step_) <1e-5{
        set cirnode to node(startime+t,0,0,dltav). //some dv
        add cirnode.
        wait 0.1.
        if cirnode:orbit:hasnextpatch{
            if abs(cirnode:orbit:nextpatch:periapsis-tgt)>last_diff{
                set step_ to -(step_/10). 
            }
            set last_diff to abs(cirnode:orbit:nextpatch:periapsis-tgt).
        }
        set dltav to dltav+step_.
        remove cirnode.
    }
    add cirnode.
    writemode(2).
    reboot.
}
else if runmode=2{
    runoncepath("1:/bric_beta.ks").
    execute_maneuver().
    writemode(3).
    reboot.
}
else if runmode=3{
    runoncepath("1:/kos.lib.ks").
    runoncepath("1:/directions.ks").
    runoncepath("1:/orbit.ks").
    until stage:number <=0{
        stage.
        wait 1.
    }
    wait 5.
    warp_to(eta:transition+60).
    until ish(periapsis,9000,500){
        if periapsis <=9000 lock dir to rad():vector.
        else lock dir to antirad():vector.
        lock steering to dir.
        wait until vang(ship:facing:vector,dir)<=1.
        lock throttle to throttctrl(9000,periapsis).
    }
    lock throttle to 0.
    writemode(4).
    reboot.
}
else if runmode=4{
    //runoncepath("1:/bric_beta.ks").
    //local dv is sqrt(2*mu(mun)/mun:radius)-velocityat(ship,time:seconds+eta:periapsis):orbit:mag+15.
    //local maneuver is node(time:seconds+eta:periapsis,0,0,dv).
    //add maneuver.
    //execute_maneuver().
    warpto(time:seconds+eta:periapsis-60).
    lock steering to retrograde .
    lock throttle to 1.
    wait until apoapsis >0 and apoapsis <=2_200_000. 
    writemode(5).
    reboot.
}
else if runmode=5{
    runoncepath("1:/sattcom.ks").
    runoncepath("1:/science.ks").
    deactivate_all().
    local startime is time:seconds.
    lock steering to -kerbin:position.
    runpath("1:/science.ks",2).
    wait min(100,eta:apoapsis-60).
    if eta:apoapsis < 300{
        activate_all().
        wait 1.
    }
    reboot.
}