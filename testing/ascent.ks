Parameter inc is 0.
parameter gforce_limit is false..
parameter booster_landing is false.
runoncepath("0:/library/bric_beta.ks").
function abortsystem{
    clearscreen.
    print "aborting".
    set throttle to 0.
    toggle abort.
    wait 1.
    until stage:number =0{
        stage.
        wait until stage:ready.
    }
    shutdown.
}
function auto_stage{
    if not (defined thrust){
    set thrust to 0.
    }
    else if not(total_deltav()=0 or stage:number=1){
        set prevthrust to thrust.
        set thrust to maxthrust .
        if thrust + 10< prevthrust or maxthrust = 0{
        print "staging" at (0,0).
        stage.
        set thrust to 0.
        wait 0.5.
        }
    }
}
function auto_rcs{
    local rcslist is list().
    for part_ in ship:parts{
        if part_:hasmodule("modulercsfx") rcslist:add(part_).
    }
    for part_ in rcslist{
        local m is part_:getmodule("modulercsfx").
        if m:allevents[0]="(callable) show actuation toggles, is kspevent"{
            m:doevent("show actuation toggles").
        }
        if stage_deltaV()=0 and maxthrust =0{
            m:setfield("fore by throttle",true).
        }
        else m:setfield("fore by throttle",false).
    }
    if stage_deltaV()=0 and maxthrust =0 rcs on.
    else rcs off.
}
function fairing{
    declare local ls is ship:partsdubbedpattern("fairing").
    for p in ls{
        local m is p:getmodule("ModuleProceduralFairing").
        m:doevent("deploy").
    }//add check if it's deployed or not //  maybe
}
//separate fairings conditional loop
when altitude >=60000 then{
    fairing().
}
local runmode is 1.
until runmode=0{//
    if runmode=1{
        stage.
        if not (defined aggregate_thrust ) local aggregate_thrust is 0.
        lock throttle to aggregate_thrust.
        until throttle >=1{
            set aggregate_thrust to aggregate_thrust+0.005.
            wait 0.01.
        }//gradual throttle up
        stage.
        set runmode to 2.
    }
    //gravity turn
    else if runmode=2{
        local pitchval is min(90,90*0.99996657661^altitude+10).
        lock steering to heading(90-inc,pitchval).
        local lock pathvec to heading(90-inc,pitchval):vector.
        local lock hdgvec to ship:facing:vector.
        local lock deviation to vectorangle(hdgvec,pathvec).
        if deviation >=15{
            abortsystem().//Initiate abort sequence if we are off course 
        }
        //add abort conditon
        if apoapsis >=70000 set runmode to 3.
    }
    //circularization
    else if runmode=3{
        //know orbital stage with deltav ?
        //do final burn 
        //apoapsis time and altitude loop then veritcal speed loop 
        local orbit_velocity is sqrt(mu()/ship:orbit:semimajoraxis).
        local apoapsis_velocity is velocityat(ship,time:seconds+eta:apoapsis):orbit.
        local circularize_dv is orbit_velocity- apoapsis_velocity:mag.// deltav needed to circularize / may be in accurate assuming gravity loss
        if burntime(circularize_dv)>eta:apoapsis{
        // try to keep us from falling
        //do what you do
            if not (defined lastecc) set lastecc to 1.
            if altitude > 70_000{
                set pitchoutput to verticalspeed*-2.
            }
            else{
                //apoapsis pid
                if not(defined apoapsis_pid){
                    global apoapsis_pid is pidloop(1e-2,6e-3,7e-3,-45,45).//
                    set apoapsis_pid:setpoint to 72_000.
                    set pitchoutput to 0.
                }
                set pitchoutput to pitchoutput+apoapsis_pid:update(time:seconds,apoapsis).
            }
            if pitchoutput <-45 set pitchoutput to -45.
            else if pitchoutput >45 set pitchoutput to 45.
            lock steering to prograde+r(0,pitchoutput,0).
            print pitchoutput at (0,5).
            if periapsis >70000 and ship:orbit:eccentricity > lastecc{
                lock throttle to 0.
                set runmode to 0.
            }
            set lastecc to orbit:eccentricity.
        }
        else execute_maneuver(circularization(circularize_dv)).
    }
    auto_rcs().
    auto_stage().
    wait 0.001.    
}

//follow ascent path
//when apoapsis >70000
//keep apoapsis constant
//if eta apoapsis <30 try to pitch up to keep it above 30 
//beware of sudden change