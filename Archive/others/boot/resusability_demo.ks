// copypath("0:/development/recovery.ks","").
wait 5.
clearScreen.
lock targetPitch to min(90,90*0.99996^altitude).
set randir to 90.
lock steering to heading(randir,targetpitch).
lock throttle to 1.
gear off.
stage.
wait until apoapsis>=40000.
stage.
// lock steering to up .
run temp.

//wait until addons:rt:HASCONNECTION(ship).
//copypath("0:/development/landing.ks","").
//wait 2.
//wait until ship:partsdubbedpattern("mk1-3pod"):length =0.
//run landing.


//breaking burn: burn extra fuel
//burn retrograde
//better navigation
//account for earth rotation ??
//bad braking burn
//if overweight ==> early burn
//if underweight ==> not enough propellant 
