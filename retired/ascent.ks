//Automated ascent script v3.1
//added a better ascent profile to avoid convection heat and aerodynamic losses 
//and ease boosters landings
//to do:
//  ascent script v3.2: implement Gforce pid loop and get rid of hardcoding
//  ascent script v4: implement runmodes and get rid of lagging loops. 

Parameter timer.
Parameter inc. 
Parameter targetaltitude.

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
function sleep{
    parameter timer.
    set last_time to time:seconds.
    until false{
        if time:seconds -last_time >= timer{
            return false.
        }
    }
}


function autostage{//debug ??
    when true then{
        if periapsis >70000 or stage:number =0{
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
            sleep(1).
            stage.
            list engines in myengines.//buffer second stage engine
            for eng in myengines{
                set eng:thrustlimit to 100.    
            }.
            }
        }
        preserve.
    }
}
function launch{
    Parameter minalt.
    autostage().
    until maxthrust =0{
        when alt:radar >minalt then{
            lock targetPitch to 1.40421e-24*alt:radar^2 - 0.000857143*alt:radar + 90. 
            set targetDirection to inc.
            set steering to heading(targetDirection, max(5,targetPitch)).
            local lock pathvec to heading(targetDirection,max(5,targetPitch)):vector.
            local lock hdgvec to ship:facing:vector.
            local lock deviation to vectorangle(hdgvec,pathvec).
            if deviation >=10{
                abortsystem().//Initiate abort sequence if we are off course 
            }
            set throttle to 4.19487e-10 *alt:radar^2 - 0.000032981 *alt:radar + 1.00033.
        }
    }
}
function circularize{
    local lock difference to targetaltitude-apoapsis .
    lock steering to heading(inc,12).
    wait 1.   
    until ALTITUDE >70000{
        lock throttle to difference *0.01.
    }
    set warp to 0.
    wait 2.
    set warp to 2.
    lock steering to prograde .
    wait until eta:apoapsis <=25.
    kuniverse:TimeWarp:CANCELWARP().
    print "Initiating Final circularization Burn".
    Eccentricity_score().
    //should be fixed
}
function Eccentricity_score{
    //local lock difference to targetaltitude+body:radius - orbit:semimajoraxis.
    wait until ETA:Apoapsis <= 5. // improve this by the delta v burn time (ma)
    //lock throttle to  0.001*(difference+100).
    lock throttle to orbit:eccentricity * 5.
    set current_score to orbit:Eccentricity.
    set prev_score to 1.
    until false{
        set prev_score to current_score.
        wait 0.001.
        set current_score to orbit:Eccentricity.
        if current_score > prev_score{
            lock throttle to 0.
            return false.  //should be in stable orbit. manual control restored.
        }
    }
}//shuts off thrust as soon as eccentricity starts rising.



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
    when alt:radar > 60000 then{
        fairing().
    }
    launch(1000).
    circularize().
    final_touches().
}
clearscreen.
info(timer).
main().
wait 5.


