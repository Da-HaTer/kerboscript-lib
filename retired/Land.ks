//suicide burn v1
//-----------------
//suicide_burn v2: 
//remove groundspeed from total speed to improve time (beware of sharp attack angle)

//suicide_burn v2.5:
//hoverscript with pid

//suicide_burn v3:
//guided landing

//d=v^2/2*a
parameter ship_height.
clearscreen.	
function main{
	lock realaltitude to alt:radar - ship_height.
	lock v to sqrt(ship:verticalspeed^2+ship:groundspeed^2).
	set g to (body:mass*constant:g)/body:radius^2.
	lock maxacc to ship:availablethrust/ship:mass.
	//Newton's second law: sum of all forces applied on a system at any time= mass*acc
	//||thrust||+||G||=Mass*acceleration.
	
	// acceleration=||thrust||+||G||/mass 
	
	until realaltitude <=3{
	await_test_conditions(). // vspeed <0
	suicide_burn().
	}
}
function await_test_conditions{
	lock throttle to 0.
	sas off. rcs on.
	lock steering to up .
	wait until verticalspeed <0.
	wait 1.// to make sure we don't instantly point to surfretro.
}
function suicide_burn{
	lock steering to safe_retrograde() .
	lock tval to deceleration_time() /time_to_impact().
	wait until time_to_impact() <= deceleration_time(). lock throttle to tval. gear on.
	wait until realaltitude <=2 or verticalspeed >-1.
	wait 0.5. lock throttle to 0. set ship:control:pilotmainthrottle to 0.
}
function safe_retrograde{
	if verticalspeed <0 return srfretrograde.
	return up.
}
function deceleration_time{
	//t=v/a
	return v/maxacc.
}
function time_to_impact{
	//d=1/2at^2+v0t
	
	local d is realaltitude.
	return (sqrt(v^2+2*g*d)-v)/g.
}
main().
wait until verticalspeed <=1 and verticalspeed >= -1 and alt:radar <200.