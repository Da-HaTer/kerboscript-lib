copypath("0:/development/landing.ks","").
wait 5.
lock targetPitch to min(90,90*0.99996657661^altitude).
lock steering to heading(90,targetpitch).
lock throttle to 1.
gear off.
stage.
wait until stage:resources[2]:amount <=2500.
stage.
lock steering to up .
run landing.

//wait until addons:rt:HASCONNECTION(ship).
//copypath("0:/development/landing.ks","").
//wait 2.
//wait until ship:partsdubbedpattern("mk1-3pod"):length =0.
//run landing.
