//launch window 
clearscreen.
//runoncepath("0:/library/orbit.ks").
//copypath("0:/library/kos.lib.ks","").

function writemode{
    parameter runmode.
    local drive is "drive.ks".
    log "" to drive.
    deletepath("1:/"+drive).
    log "set runmode to "+runmode to drive.
}
function readmode{
    local drive is "drive.ks".
    log "" to drive.
    runpath("1:/"+drive).
}
set runmode to 0.
readmode().
when maxthrust =0 and runmode<>0 then{
    if stage:number >1 {
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
    warpto(time:seconds+t-10).
    runpath("0:/library/ascent.ks",75_000,t).
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
    local step_ is 0.5.
    local hadpatch is false.
    set tgt to 50_000.
    until abs(step_) <1e-5{
        set cirnode to node(startime+t,0,0,dltav). //some dv
        add cirnode.
        wait 0.1.
        if cirnode:orbit:hasnextpatch{
            set hadpatch to true.
            set ob to cirnode:orbit:nextpatch.
            if ob:hasnextpatch{
                if abs(ob:nextpatch:periapsis-tgt)>last_diff{
                    set step_ to -(step_/10). 
                }
                set last_diff to abs(ob:nextpatch:periapsis-tgt).
            }
        }
        if hadpatch and not(cirnode:orbit:hasnextpatch){
            set step_ to -(step_/10). 
            set hadpatch to false.
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
    warp_to(eta:transition+60).
    if periapsis <=9000 lock dir to rad().
    else lock dir to antirad().

    lock steering to dir.
    wait until vang(ship:facing:vector,dir:vector)<=1.

    lock throttle to throttctrl(periapsis,9000).
    wait until periapsis >8990 and periapsis <9010.
    writemode(4).
    reboot.
}
else if runmode=4{
    runoncepath("1:/bric_beta.ks").
    set dv to sqrt(2*mu(mun)/mun:radius)-ship:orbit:velocityat(time:seconds+eta:periapsis)+3.
    set maneuver to node(time:seconds+eta:periapsis,-dv,0,0,0).
    execute_maneuver().
    writemode(5).
    reboot.
}
else if runmode=5{
    runoncepath("1:/sattcom.ks").
    runoncepath("1:/science.ks").
    deactivate_all().
    local startime is time:seconds. 
    until time:seconds - startime >30{
        runpath("1:/science.ks").
        wait 1.
    }
    activate_all().
    wait 5.
    reboot.
}

//3000 disk upgrade.

local dltav is 800.
    local last_diff is 1e8.
    local step_ is 0.5.
    local hadpatch is false.
    set tgt to 9_000.
    until abs(step_) <1e-5{
        set cirnode to node(startime+t,0,0,dltav). //some dv
        add cirnode.
        wait 0.1.
        if cirnode:orbit:hasnextpatch{
            set hadpatch to true.
            set ob to cirnode:orbit:nextpatch.
            if ob:hasnextpatch{
                if abs(ob:nextpatch:periapsis-tgt)>last_diff{
                    set step_ to -(step_/10). 
                }
                set last_diff to abs(ob:nextpatch:periapsis-tgt).
            }
        }
        if hadpatch and not(cirnode:orbit:hasnextpatch){
            set step_ to -(step_/10). 
            set hadpatch to false.
        }
        set dltav to dltav+step_.
        remove cirnode.
    }