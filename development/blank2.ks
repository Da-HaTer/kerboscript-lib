//ascent test

parameter azimuth is 90.

function tiltofalt{
    parameter x.
    //return -2.0238095238095237e-8*x^2+0.000130952*x+90.
    return 
}

function throttleup{
    if not (defined aggregate_thrust ) local aggregate_thrust is 0.
    lock throttle to aggregate_thrust.
    until throttle >=1{
        set aggregate_thrust to aggregate_thrust+0.005.
        wait 0.01.
    }
}

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

lock tilt to max(0,min(89.5,tiltofalt(altitude))).


wait until maxThrust >0. //wait for ignition
throttleup().
releaseclamps().
lock steering to heading(azimuth,89.5).
wait until verticalSpeed >= 80.
lock targetvec to heading(azimuth,tilt):vector.
lock fixvec to targetvec*1.5-ship:srfprograde:vector.
lock steering to fixvec.
wait until false.

//todo : prograde instead once inclination right
