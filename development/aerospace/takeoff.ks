
wait 1. clearscreen.
lock rw to latlng(-0.048515,-74.7155075073242):position.
//west side
lock re to latlng(-0.050117,-74.501998989013672):position.
//east side
lock rv to re-rw.
on abort{
	print "abort".
	unlock throttle .
	set ship:control:neutralize to true.
	sas on.
	if re:mag >rw:mag and status<>"flying"{
		brakes on.
		set throttle to 0.
		}
	//alert("autopilot aborted, manual control in charge",5).
	reboot.
}
local main is{
	sas off.
	rcs off.
	brakes on.
	brakes off.
	set natural_pitch to vang(ship:facing:vector,relative_radar_vector(ship:facing:vector)).
	//runway vector fro west to east
	ignition().
	//if engines not ingited stage
	print "steer".
	until ship:status="flying" steer().
	//slowly steer towards correct path on low thrust
	//takeoff().
		//once almost on correct path throttle up gradually and fire up pid loops (yaw and pitch )
	//ascend().
		//once in air ascend to target altitude
}.
function ignition{
	print "ingnition".
	local ignition_state is false.
	list engines in egnines_.
	for engine in egnines_{
		if engine:ignition set ignition_state to true.
	}
	if ignition_state return false.
	else {
		stage.
		return true.
	}
}
function steer{
	if 	airspeed >=80 or (re:mag <=150 and ship:status<>"flying") set ship:control:pitch to 0.5.
	else set ship:control:pitch to 0.1.
	///pid loop to control pitch angle better
	//pitch_seek(angle)
	//yaw_seek(vector)
	//roll_seek(angle)
	if not (defined init_thrott) set init_thrott to 0.1.
	lock throttle to init_thrott.
	if not (defined startime) set startime to time:seconds.
	yaw_ctrl(rv).
	if startime+15 <=time:seconds{
		if ish(yaw_pid:pterm,0,0.1) and vang(ship:facing:vector,rv)- natural_pitch <=2 set init_thrott to min(1,init_thrott+0.05).
	}
}	

function aligned_runway{
	local re is latlng(-0.048515,-74.7155075073242):position.
	//vector pointing to the east end of runway
	if vdot(ship:facing:vector:normalized,re:normalized)>0 return true.
	//plane pointing in the same direction as take off direction
	else return false.
}

if not aligned_runway(){
	print "plane not properly aligned with runway".
	print "please align it manually".
	wait until false.
}
else{
	main().
	set ship:control:yaw to 0.
	wait 5.
	gear off.
	set ship:control:neutralize to true.
	unlock throttle .
	set ship:control:pilotmainthrottle to 1.
	sas on.
}



function yaw_ctrl{
	parameter input_vector.
	if not(defined yaw_pid){
		//global yaw_pid is pidloop(1e-6,1e-7,1e-2,-1,1).//
		global yaw_pid is pidloop(1e-6,1e-5,1e-7,-1,1).//
		set yaw_pid:setpoint to 0.
		if ship:control:yaw <>0 global yaw_output is ship:control:yaw.
		else global yaw_output is 0.
	}
	local lock yaw_angle to vang(relative_radar_vector(re),relative_radar_vector(ship:facing:vector)).
	set runway_y to VCRS(input_vector,up:vector).
	set ship:control:yaw to yaw_output.
	if vang(runway_y,ship:facing:vector) <90 set yaw_input to -yaw_angle. 
	else set yaw_input to yaw_angle.
	set yaw_output to yaw_output+yaw_pid:update(time:seconds,yaw_input).
	return yaw_output.
}//lock pitch to a given angle
function ish{
	parameter a.
	parameter b.
	parameter ishyness.
	
	return a+ishyness>b and a- ishyness <b.
}

function relative_radar_vector{
	parameter vec.
	local v_ is vec:normalized. //unit pointing vector
	local k1 is vdot(v_,north:vector). //vdot with north vector
	local k2 is vdot(v_,north+r(0,-90,0):vector). //vdot with east vector
	return k1*north:vector+k2*(north+r(0,-90,0):vector).
}//compass vector


