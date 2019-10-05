//ascent trajectory
function GVEC{
    parameter vec.//vector end
    parameter name is "N/A".
    parameter color is rgb(random()*3,random()*3,random()*3).
    return vecdraw(
        v(0,0,0),
        vec,
        color,
        name,
        10,
        true,
        0.01
    ).
} //dra


//second equation:
//set pitch to 90*e^(5/(targetaltitude+20_000)*-altitude).
//thrid equation:
//setg pitch to max(0,100*constant:e^(x/25000).

set azimuth to 90.
set locup to heading(azimuth,0):vector*-1.

set targetaltitude to 75000.
set tgtw to sqrt(kerbin:mass*constant:g/(targetaltitude+600_000)). //final vctor
lock vecpitch to max(-15,min(90,100*0.1^(altitude /targetaltitude))).

when altitude >=40_000 then lock tgtvec to heading(azimuth,vecpitch-10):vector.
lock tgtvec to heading(azimuth,vecpitch):vector-srfprograde:vector*tan(0.5).// fixvec at launch
//lock fixvec to tgtvec+(log10(altitude))*(tgtvec-ship:srfprograde:vector).
lock fixvec to (tgtvec*(tgtw*1.5)-ship:prograde:vector*ship:velocity:orbit:mag):normalized. 
stage.
lock throttle to 1.
wait 5.
stage.
lock steering to lookdirup(tgtvec,locup).
wait until verticalspeed >20.
wait until vang(fixvec,ship:srfprograde:vector) <1.
lock steering to lookdirup(fixvec,locup).
set v1 to GVEC(ship:srfprograde:vector,"prograde").
set v1:vecupdater to {return ship:srfprograde:vector.}.

set v2 to GVEC(tgtvec,"target").
set v2:vecupdater to {return tgtvec.}.

set v3 to GVEC(fixvec,"fix").
set v3:vecupdater to {return fixvec.}.

when true then {
	print vecpitch at (0,5).
	print fixvec:mag at (0,6).
	print tgtvec:mag at (0,7).
	preserve.
}
wait until false.
