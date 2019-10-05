function slice{
	parameter enumrable.
	parameter startpos.
	declare parameter endpos is 0.
	
	local I is enumrable:iterator. 
	local result is "".
	
	if endpos <= 0{
		UNTIL not I:NEXt or I:index = enumrable:length+ endpos {
	    	if I:index>=startpos{
		    	set result to result + I:VALUE.
		    }
		}
	}
	else if endpos>0{
		UNTIL not I:NEXt or I:index =endpos {
	    	if I:index>=startpos{
		    	set result to result + I:VALUE.
		    }	
		}	
	}
	return result. //finally
}//slice enumerable
function ish{
	parameter a.
	parameter b.
	parameter ishyness.
	
	return a+ishyness>b and a- ishyness <b.
}
function kscrange{
	libreq("Orbit.ks").
	local angle is arcsin(600_000/min(orbit:semimajoraxis,orbit:semiminoraxis)).
	return angle(ship)>lng(285.44-angle) and angle(ship)<lng(285.44-angle).
}
global throttctrl is{ // i don't fucking know okay ?
    parameter a.
    parameter b.
    if (a =0 or b=0) {
        set a to a+100.
        set b to b+100.
    }
    set p to floor(log10(max(a,b))).
    set d to abs(floor(a-b))*10^(-p).
    print "power "+p at(0,15).
    print "output "+(d+0.01) at (0,16).
    return d+0.005.
}.
global colinear is {
	parameter v1.
	parameter max_error_angle is 10.
	parameter v2 is ship:facing:vector.
	return vang(v1,v2) <=max_error_angle.
}.