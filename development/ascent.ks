//Automated ascent script v3.1
//added a better ascent profile to avoid convection heat and aerodynamic losses 
//and ease boosters landings
//todo:
//implement precise launch auzimuth and fix the code below
//v3.2

//beta better ??
    lock site_lng to longitude-body:rotationangle . // +-
    set site_lat to latitude.
    set site_angv to body:angularVel*cos(latitude*constant:degtorad)*body:radius.// rotation angle at lauch site
    set tgt_lat_max to cos(constant:pi/2-tgt_inc*constant:degtorad)*body:radius.
    set interct_point_1 to (3*pi-arcSin(site_lat/tgt_lat_max))*body:radius.
    set interct_point_2 to (2*pi+arcSin(site_lat/tgt_lat_max))*body:radius.
    //beta part above

//launch windows (if targetted).
    function tgt_eta{
    parameter tgt_inc is false.
    parameter tgt_lan is false.
    if hasTarget{
            set tgt_inc to target:obt:inclination.
            set tgt_lan to target:obt:lan.
        }
        function lng{ //calculates angles in better range
            parameter x. // longitude / latitude
            return mod(x+360,360).
        }
        lock site_lng to lng(longitude+body:rotationangle) . // +-
        set site_angv to body:angularVel:mag*cos(latitude)*body:radius.// rotation angle at lauch site
        //set tgt_lat_max to cos(constant:pi/2-tgt_inc*constant:degtorad)*body:radius.
        if tgt_inc <=latitude return 0.
        set interct_point_1 to lng(180-arcSin(latitude/tgt_inc)+tgt_lan+latitude). // arcSin of sin/sin
        set interct_point_2 to lng(arcSin(latitude/tgt_inc)+tgt_lan-latitude).  
        set angle to min(lng(interct_point_1-site_lng),lng(interct_point_2-site_lng)).
        set t to angle/kerbin:angularVel:mag*constant:degtorad.
        return t.
    }
    clearscreen.
    print tgt_eta() at (0,7).
    warpto(time:seconds+tgt_eta()-15).  
    wait 5.
//ascent
{

    //Parameter targetaltitude.
    //Parameter timer is 1.
    Parameter inc is 0.
    parameter gforce_limit is false..
    parameter booster_landing is false.
    runoncepath("0:/library/bric_beta.ks").
    

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
            releaseclamps().
            set runmode to 2.
        }
        //gravity turn
        else if runmode=2{
            local lock tilt to heading(90-inc,min(90,90*0.99996657661^altitude+10)).
            local lock hdgvec to ship:facing:vector.
            local lock deviation to vectorangle(hdgvec,tilt:vector).
            lock steering to tilt.
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
        print all_stages_deltav() at (0,0).
        print "total isp"+totalISP() at (0,7).
        print "active isp"+activeISP() at (0,9).
     
        wait 0.001.    
    }

}
//Aproach #1 
//pid loops + if else conditions

//result : blind af


//Aproach #2
//control burntimes only (no trajectory control)

lock orbit_velocity to sqrt(mu()/ship:orbit:semimajoraxis).
lock apoapsis_velocity to velocityat(ship,time:seconds+eta:apoapsis):orbit.
lock circularize_dv to orbit_velocity- apoapsis_velocity:mag.// deltav needed to circularize / may be in accurate assuming gravity loss
if burntime(circularize_dv)>eta:apoapsis{
    // try to keep us from falling
    //do what you do
    
}
else execute_maneuver(circularization(circularize_dv))


//Aproach #3
// in theory should be most effecient path 
// requires trajectory tunning and calculation, specific requirments etc.. otherwise coast implement
window()
launch(sma,inclination)
    countdown 
    ignition
    releaseclamps
    roll program
    pitch program
    insertion
maneuvers()
replace maneuvers with vectors
 
// apoapsis then periapsis

//a better and more effecient appraoch can be made by approximating desired velocity (vector) and correcting current velocity upon error (difference)
// requirements: ship needs to have a relatively low twr to take the time to reach the desired target altitude, otherwise the desired orbital velocity will be reached while still in atmosphere

//todo:
// 1 make equation reach tgt asap (differential)
// 2 follow fix vector 

//conditions:
// parking orbit can range from 72km to 75km 
// no sudden reverse of vector

//totest:
// fix vector : 
// fix upon verticalSpeed (alpha=verticalspeed*TGO/2)>> low level 
// fix upon vector (ez+ high level)


// twr not possible with low mass vehicle (thrust relatively high)
// >>launch more steeper still