    //Automated ascent script v3.1
//added a better ascent profile to avoid convection heat and aerodynamic losses 
//and ease boosters landings
//to do:
//  ascent script v3.2: implement Gforce pid loop and get rid of hardcoding
//  ascent script v4: implement runmodes and get rid of lagging loops. 

//-----------------------------------------
//better : get to 2km lower than target then boost apoapsis to target apoapsis then circularize

//v3.2
//orbital velocity = sqrt(µ/r)

//problems: first stage overshoots
//          seconds stage lag when condition
//          won't start engines at circularization point
// node works but needs more time also get rid of lag and unnecessary loops.
//make function for for deviation

Parameter targetaltitude.
Parameter timer is 1.
Parameter inc is 90.
parameter booster_landing is false. 


function abortsystem{
    clearscreen.
    print "aborting".
    set throttle to 0.
    toggle abort.
    wait 1.
    until stage:number =0{
        stage.
        wait 0.5.
    }
    shutdown.
}
function fairing{
    declare local ls is ship:partsdubbedpattern("fairing").
    for p in ls{
        local m is p:getmodule("ModuleProceduralFairing").
        m:doevent("deploy").
    }
}
function auto_rcs{
    local rcslist is list().
    for part_ in ship:parts{
        if part_:hasmodule("modulercsfx") rcslist:add(part_).
    }
    when true then{
        for part_ in rcslist{
            local m is part_:getmodule("modulercsfx").
            if m:allevents[0]="(callable) show actuation toggles, is kspevent"{
                m:doevent("show actuation toggles").
            }
            if maxthrust=0 and status<>"prelaunch"{
                //rcs on.
                m:setfield("fore by throttle",true).
            }
            else m:setfield("fore by throttle",false).
        }
        preserve.
    }
}
function autostage{//debug ??
    when true then{
        if altitude >70000 or stage:number =0{
            return false.
        }
        if not (defined thrust){
        set thrust to 0.
        }
        else {
            set prevthrust to thrust.
            set thrust to maxthrust .
            if thrust + 10< prevthrust or maxthrust = 0{
            print "staging" at (0,0).
            stage.
            set thrust to 0.
            sleep(1).
            }
        }
        preserve.
    }
}
function launch{
    Parameter minalt.
    autostage().
    auto_rcs().
   until apoapsis>68_000{
        when alt:radar >minalt then{
            //if cond=1{lock targetPitch to 1.40421e-24*alt:radar^2 - 0.000857143*alt:radar + 90. }
            //else lock targetPitch to 1.40421e-24*alt:radar^2 - 0.000857143*alt:radar + 90. 
            //else{lock targetPitch to 1.48423e-10*alt:radar^2 - 0.00100831 *alt:radar + 89.8909.}
            

            lock targetPitch to min(90,90*0.99996657661^altitude).
            //lock targetPitch to min(90,90*0.99996657661^altitude +10).

            set targetDirection to inc.
            set steering to heading(targetDirection, max(5,targetPitch)).
            local lock pathvec to heading(targetDirection,max(5,targetPitch)):vector.
            local lock hdgvec to ship:facing:vector.
            local lock deviation to vectorangle(hdgvec,pathvec).
            if deviation >=10{
                abortsystem().//Initiate abort sequence if we are off course 
            }
            set throttle to 1.//4.19487e-10 *alt:radar^2 - 0.000032981 *alt:radar + 1.00033.
        }
    }
}
function circularize{
    //if stage_deltav()<700 stage. //get rid of booster if not already separated
    local lock difference to targetaltitude-apoapsis .
    //lock steering to heading(inc,7).// add pid loop
    lock steering to prograde . 
    wait 1.
    when alt:radar > 60000 then{
        fairing().
    }   
    until ALTITUDE >70000{
        lock throttle to difference *0.01.
        wait 0.001.
    }
    set warp to 0.
    set node to maneuver().
    add node.
    lock dv to node:deltav:mag.
    lock steering to node:deltav.
    set burntime to burntime(dv)+0.5. // debug
    if not(eta:apoapsis<burntime/2+20) warp_to(eta:apoapsis-burntime/2-2).
    wait until eta:apoapsis<=burntime/2.
    print "Initiating Final circularization Burn".
    lock throttle to dv/100+0.001.
    wait until dv<=0.05.
    unlock steering .
    remove node.    
    lock throttle to 0.
    //should be fixed // replace with execute maneuver
}

function maneuver{
    local dltav is 0.
    local last_ecc is 1.
    local step_ is 1000.
    until abs(step_) <1e-3{
        set cirnode to node(time:seconds+eta:apoapsis,0,0,dltav). //some dv
        add cirnode.
        wait 1e-3.
        if not (cirnode:orbit:Eccentricity<last_ecc){
            set step_ to -(step_/10).   
        }
        set dltav to dltav+step_.
        set last_ecc to cirnode:orbit:Eccentricity.
        remove cirnode.
    }
    return cirnode.
}

function final_touches{
    if periapsis >= 70000 and orbit:eccentricity < 0.5{
        print "low kerbin orbit achieved".
    }
    else {
        print "Warning! orbit failed".
    }
    set loworbitlogs to ship:name+".Ascent.logs.txt".
    log ("Apoapsis:  "+round((apoapsis),2)) to loworbitlogs.
    log ("Periapsis:  "+round((periapsis),2)) to loworbitlogs.
    log ("average:  ")+round((apoapsis+periapsis)/2,2) to loworbitlogs.
    log ("Orbit Eccentricity:  "+orbit:ECCENTRICITY) to loworbitlogs.
    log ("Inclination: "+orbit:inclination) to loworbitlogs.
    log ("Period: "+orbit:period) to loworbitlogs.
    //orbital tuple
    //deltav
    //fuel
}

function countdown{
    parameter timer.//local param
    If alt:radar < 70 and verticalspeed > -1 and verticalspeed < 1 { //assume we are on the launchpad
        print "counting down".
        lock throttle to 1.
        lock steering to heading(inc,90) .
        FROM {local T is timer.} UNTIL T = 0 STEP {set T to T-1.} DO {
            if T>9 {
                print ("  T-"+"00:00:"+T) at (0,terminal:height-2).
            }
            else {
                print ("  T-"+"00:00:0"+T) at (0,terminal:height-2).
            }
            wait 1.
        }
    }           
    stage.
    print "liftoff".
}

function info{
    parameter timer.// countodwn timer 
    countdown(timer).
    when true then{ 
        seconds().
        minutes().
        hours().
        print ("  T+ "+h+":"+m+":"+s) at (0,terminal:height-2).
        print ("SPEED:"+round((sqrt(groundspeed^2+verticalspeed^2))*3.6,2)+" Km/h") at (0,terminal:height).
        print ("ALTITUDE:"+round((alt:radar)/1000,2)+" Km") at (21,terminal:height).
        preserve.
    }
    function seconds{
        if mod(missiontime,60) > 9{ 
            global s is floor(mod(missiontime,60)).
        }
        else {
            global s is ("0"+ floor(mod(missiontime,60))).
        }
    }
    function minutes{
        if (mod(missiontime,3600) / 60) > 9{
            global m is floor(mod(missiontime,3600) / 60).
        }
        else{
            global m is ("0"+floor(mod(missiontime,3600) / 60)).
        }
    }   
    function hours{
        if (missiontime / 3600) > 9 {
            global h is floor(missiontime / 3600).
        }
        else {
            global h is ("0"+floor(missiontime / 3600)).
        }
    }
}

function main{
    copypath("0:/library/BRIC_beta.ks","").
    runoncepath("BRIC_beta.ks").
    launch(500).
    circularize().
    final_touches().
}
clearscreen.
info(timer).
main().
wait 5.