//suicide burn v3
//-----------------
//suicide_burn v2: 
//remove groundspeed from total speed to improve time (beware of sharp attack angle)

//suicide_burn v2.5:
//hoverscript with pid

//suicide_burn v3:
//guided landing

//landing v4:
//added braking burn and increased boostback velocity
//might require slightly more fuel

//d=v^2/2*a
parameter guided is true.
//libreq("bric_beta.ks").
wait until addons:rt:HASCONNECTION(ship).
//copypath("0:/library/bric_beta.ks","").
runoncepath("0:/library/bric_beta.ks").
local start_time is time:seconds.
clearscreen.
if hastarget local tgt is latlng(target:latitude,target:longitude).	
else if guided local tgt is latlng(-0.0972030237317085,-74.5576019287109). //launcpad 
//else global tgt is latlng(-0.0978078842163086,-74.6201782226563). //launcpad
local lock ground_distance to (tgt:position-latlng(latitude ,longitude ):position):mag .
local ship_height is vessel_height().
local lock realaltitude to alt:radar-ship_height.
local lock maxacc to ship:availablethrust/ship:mass.
local lock v to sqrt(ship:verticalspeed^2+ship:groundspeed^2).
function main{
	lock throttle to 0.
	until realaltitude <=3{
	boostback_and_brake(). // vspeed <0
	suicide_burn().
	}
}
function boostback_and_brake{
	sas off. rcs on.
	if guided{
		if not (ground_distance >=200_000) 
		boostback(). // does this line work ??
	}
	lock steering to relative_radar_vector(retrograde:vector).
	wait until verticalspeed <=-1.
	lock steering to retrograde.
	wait 10. rcs off.
	brakes on.
	// new part here
		//local lock attackangle to vang(relative_radar_vector(ship:facing:vector),ship:facing:vector).

		//local lock stoptime to (groundspeed-70)/(ship:availablethrust*cos(attackangle)). 
		//local lock reachtime to ground_distance*groundspeed . 

	wait until ground_distance <=2500 or velocity:surface:mag >=750 or altitude <=13000.
	if altitude>=13000 or velocity:surface:mag >=750{
		lock throttle to 1.
		lock steering to srfretrograde:vector*0.1+relative_radar_vector(-tgt:position:normalized+srfretrograde:vector).
		wait until velocity:surface:mag <=500 and groundspeed <=20.
		lock throttle to 0.
	}
	//new part
	lock steering to steering_control() .
}
function suicide_burn{
	wait until impact_time() <= deceleration_time() and alt:radar<=5000.
	lock throttle to deceleration_time() /impact_time().
	gear on.
	wait until realaltitude <=2 and verticalspeed >-1.
	lock throttle to 0.
	set ship:control:pilotmainthrottle to 0.
}
function steering_control{
	if guided{
		if throttle =0 {
			if ground_distance >=20 and vang(up:vector,-tgt:position)>5 and altitude >500{ 
				return head_for(tgt,-70).//-tgt:position:normalized+10*(-tgt:position:normalized-srfretrograde:vector).
				}
			else return -tgt:position:normalized+10*(-tgt:position:normalized-srfretrograde:vector).
		}
		//when engines are on
		if not (ground_distance >500 or realaltitude <40 or ground_distance<=5 or vang(srfretrograde:vector,up:vector)>15){
			local angle is 50.
			set pid to pidloop(0.1,0.1,2).
			set pid:setpoint to 0. 
			until alt:radar <10 or vang(srfretrograde:vector,up:vector)>30{
				set angle to angle+pid:update(time:seconds,ground_distance).
				return head_for(tgt,angle)*2+srfretrograde:vector.
			}
		}
	}		
	return srfretrograde:vector+up:vector.
}
function deceleration_time{
	//t=v/a
	//local v is abs(ship:verticalspeed).
	if maxacc <>0 return v/maxacc.
}
function boostback{
	if verticalspeed >2 local impactime is eta:apoapsis+impact_time(apoapsis).
	else local impactime is impact_time(alt:radar).
	local lock angle to max(70,min(90,(ground_distance/50))).
	lock steering to head_for(tgt,max(40,angle)).
	wait until colinear(head_for(tgt,max(40,angle)),5). lock throttle to 1.
	wait until vdot(head_for(tgt,90):normalized,srfprograde:vector:normalized) >0 .
	//wait until groundspeed *impactime >=sqrt(abs(tgt:position:mag^2-realaltitude^2))*tgt:position:mag/realaltitude or ground_distance<=50.
	wait until groundspeed *impactime >=5000+ground_distance*tgt:position:mag/realaltitude or ground_distance<=50.
	//increase 5000 if undershooting (5km)
	lock throttle to 0.
}
global colinear is {
	parameter v1.
	parameter max_error_angle is 10.
	parameter v2 is ship:facing:vector.
	return vang(v1,v2) <=max_error_angle.
}.
function relative_radar_vector{
	parameter vec.
	local v_ is vec:normalized. //unit pointing vector
	local k1 is vdot(v_,north:vector). //vdot with north vector
	local k2 is vdot(v_,north+r(0,-90,0):vector). //vdot with east vector
	return k1*north:vector+k2*(north+r(0,-90,0):vector).
} //direction proportional to ground plan

function head_for{
	parameter coordinates.
	parameter alpha.
	lock relative_vec to relative_radar_vector(coordinates:position)*tan(alpha).
	lock target_vec to relative_vec+up:vector.
	return target_vec.
	// locking steering to a diretion of 1+1=>45deg
}
main().
wait until verticalspeed <=1 and verticalspeed >= -1 and alt:radar <200.
log time:seconds- start_time to ("0:/mylogs.txt").
lock steering  to up.
wait 5.

//remember what i told u about my landing script
//it can't guess actual landing position because calculations including aerodynamics are hard af
//but it makes a rough estimate and relies on aerodynamic guidance to get there
//well that turns out to be inaccurate
//what i have in mind is increase boostback velocity by some factor  so the virtual landing point skips the targeted area
//but then i implement a braking burn just like irl because i've been getting some thermal effects but mainly to improve trajectory

//TODO : IMPORTANT
//keep in mind attack angle to find horizental force and then guess burntime and time to pass above site 