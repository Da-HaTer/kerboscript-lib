//Automated ascent script v3.1
//added a better ascent profile to avoid convection heat and aerodynamic losses 
//and ease boosters landings
//todo:
//implement precise launch auzimuth and fix the code below
//v3.2

    Parameter inc is 90.
    parameter gforce_limit is false..
    parameter booster_landing is false.
    runoncepath("0:/library/bric_beta.ks").
    clearscreen.
    set config:ipu to 1200.
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
    function abortsystem{
        clearscreen.
        //add alarm sound
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
        else if not( stage:number=1){//total_deltav()=0 or
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
        if runmode=1{//launch
            stage.
            if not (defined aggregate_thrust ) local aggregate_thrust is 0.
            lock throttle to aggregate_thrust.
            until throttle >=1{
                set aggregate_thrust to aggregate_thrust+0.01.
                wait 0.001.
            }//gradual throttle up
            releaseclamps().
            stage.
            lock steering to lookdirup(up:vector,heading(inc,0):vector).
            wait 5.
            set runmode to 2.
        }
        //gravity turn
        else if runmode=2{
            if altitude >=20000 local progvec is prograde:vector .
            else local progvec is srfprograde:vector.
            //local angleofalt is 90*constant:e^(6*altitude/70_000).
            local angleofalt is max(-15,min(90,100*0.1^(altitude /70_000))).
            local targetvec is heading(inc,angleofalt):vector.//changeme: azimuth
            local hdgvec to ship:facing:vector.
            local correctvec is 3*targetvec-progvec.
            local deviation is vectorangle(hdgvec,correctvec).
            lock steering to lookdirup(correctvec,heading(inc,0):vector).//changemeazimuth.
            if deviation >=15 and altitude>2000{
                abortsystem().//Initiate abort sequence if we are off course 
            }
            if apoapsis >=75000 {
                lock throttle to 0.
                set runmode to 3.
            }
        }   
        //circularization
        else if runmode=3{
            //know orbital stage with deltav ?
            //do final burn 
            //apoapsis time and altitude loop then veritcal speed loop 
            local orbit_velocity is sqrt(mu()/(600_000+apoapsis))*velocityat(ship,time:seconds+eta:apoapsis):orbit:normalized.
            local apoapsis_velocity is velocityat(ship,time:seconds+eta:apoapsis):orbit.
            local circularize_dv is orbit_velocity:mag- apoapsis_velocity:mag.// deltav needed to circularize / may be in accurate assuming gravity loss
            if stage_deltaV() < circularize_dv {
                until maxthrust >0 {
                    stage.
                }
            }
            lock steering to lookdirup(orbit_velocity,kerbin:position). //maneuver node
            local Bt is 9.81*ship:mass*activeISP()*(1-constant:E^(-circularize_dv/(9.81*activeISP())))/availablethrust.
            warpto(time:seconds+eta:apoapsis-Bt).
            wait until kuniverse:timewarp:issettled and warp=0. 
            if Bt/2>eta:apoapsis{
                lock throttle to 1.
                //wait until ship:velocity:orbit:mag >= orbit_velocity:mag. // will generally overshoot (not a problem)
                wait bt.
                Lock throttle to 0.
                set runmode to 0.
            }
        }
        //auto_rcs().
        auto_stage().
        //print all_stages_deltav() at (0,0).
        //print "total isp"+totalISP() at (0,7).
        //print "active isp"+activeISP() at (0,9).  
    }
//issues: 
//usless autorcs
//lag 
//circularize burn innacurate especially without variable node vector.