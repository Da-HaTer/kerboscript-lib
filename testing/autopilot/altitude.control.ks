
function relative_radar_vector{
	parameter vec.
	local v_ is vec:normalized. //unit pointing vector
	local k1 is vdot(v_,north:vector). //vdot with north vector
	local k2 is vdot(v_,north+r(0,-90,0):vector). //vdot with east vector
	return k1*north:vector+k2*(north+r(0,-90,0):vector).
}//compass vector

function roll_ctrl{
	parameter input_angle is 0. // R>>negative L>> positive
	if not(defined roll_pid){
		global roll_pid is pidloop(1e-5,1e-7,1e-4,-1,1).
		set roll_pid:setpoint to 0.
		global roll_output is ship:control:roll.
	}
	if input_angle<=0 set roll_angle to vang(-ship:facing:starvector,relative_radar_vector(-ship:facing:starvector))+input_angle.
	else set roll_angle to vang(ship:facing:starvector,relative_radar_vector(ship:facing:starvector))-input_angle.
	set ship:control:roll to roll_output.
	if vang(up:vector,ship:facing:starvector) <90+input_angle set roll_input to -roll_angle.
	else set roll_input to roll_angle.
	set roll_output to roll_output+roll_pid:update(time:seconds,roll_input).
	return roll_output.
}// lock roll to given angle 

function pitch_ctrl{
	parameter input_angle.
	if not(defined pitch_pid){
		global pitch_pid is pidloop(1e-3,1e-7,1e-6,-1,1).//
		set pitch_pid:setpoint to 0.
		if ship:control:pitch <>0 global pitch_output is ship:control:pitch.
		else global pitch_output is 0.3.
	}
	local lock pitch_angle to vang(ship:facing:vector,relative_radar_vector(ship:facing:vector)).
	set ship:control:pitch to pitch_output.
	if vang(ship:facing:vector,up:vector)>90-input_angle set pitch_input to -pitch_angle. 
	else set pitch_input to pitch_angle.
	set pitch_output to pitch_output+pitch_pid:update(time:seconds,pitch_input).
	return pitch_output.
}
function verticalSpeed_ctrl{
	parameter vertical_speed_input.
	if not(defined vertical_speed_pid){
		global vertical_speed_pid is pidloop(1e-3,1e-9,1e-4,-1,1).//
		global vertical_speed_output is ship:control:pitch.
		//else global vertical_speed_output is 0.3.
	}
	IF verticalspeed <vertical_speed_input set vertical_speed_pid:ki to 1e-3.
	else set vertical_speed_pid:ki to 1e-4.
	set vertical_speed_pid:setpoint to vertical_speed_input.
	//local lock vertical_speed_angle to vang(ship:facing:vector,relative_radar_vector(ship:facing:vector)).
	set ship:control:pitch to vertical_speed_output.
	// if vang(ship:facing:vector,up:vector)>90-input_angle set vertical_speed_input to -vertical_speed_angle. 
	//else 
	set vertical_speed_output to vertical_speed_output+vertical_speed_pid:update(time:seconds,verticalspeed ).
	return vertical_speed_output.
}
function yaw_ctrl{
	parameter input_vector.
	if not(defined yaw_pid){
		global yaw_pid is pidloop(1e-6,1e-7,1e-2,-1,1).//
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

clearscreen.
local input_angle is 0.
local should_levelup is true.
local lock pitch_error to abs(vang(ship:facing:vector,relative_radar_vector(ship:facing:vector))).
local is_settled is false.
on abort{
	set ship:control:neutralize to true.
	sas on.
	reboot.
	preserve.
}
//abort autopilot operations
on lights {
	clearscreen.
	if input_angle >=-55 set input_angle to input_angle -5.
	preserve.
}
on brakes {
	clearscreen.
	if input_angle<=55 set input_angle to input_angle +5.
	preserve.
}
//manual controlling with action groups (not prefreferable atm)
when true then{
	if hastarget and is_settled{
		if vdot(relative_radar_vector(target:position),relative_radar_vector(ship:facing:starvector))<=0 {
			set input_angle to min(60,max(0,vang(relative_radar_vector(target:position),relative_radar_vector(ship:facing:vector)))).//gradiual funnction
		}
		else set input_angle to max(-60,min(0,-vang(relative_radar_vector(target:position),relative_radar_vector(ship:facing:vector)))).
	}
	preserve.
}
//affects bank angle given a target 
function ish{
	parameter a.
	parameter b.
	parameter ishyness.
	
	return a+ishyness>b and a- ishyness <b.
}
function level_up{
	//if throttle >0 local pitch_angle is 5.
	//else local pitch_angle is -10.
	//replace with parameter.
	if not (defined init_time) set init_time to time:seconds.
	set input_angle to max(-10,1-1.085^(2*(altitude-300))).
	pitch_ctrl(input_angle).
	if time:seconds- init_time >15{
		if ish(vertical_speed_pid:pterm,0,0.1) and ish(roll_pid:pterm,0,0.1){
			return true.
			//preserving
		}
	}
}//level up given engine condition	
sas off.
when ish(vang(up:vector,ship:facing:starvector),90,0.005) then{
	set is_settled to true.	
	//print "settled".
}
//next mode condition 

until false{ // replace with condition
	print input_angle at (0,5).
	roll_ctrl(0).
	if pitch_error>=5 or verticalspeed <=-20 or input_angle <> 0 level_up().
	wait 0.001.
}

/////////////////////////////////////////////////////////////////////////////
num5 reset pitch 
down arrow rotate vector +5 degree
up arrow rotate vector -5 degrees
right arrow rotate right (normal to compass(heading,up)).
left arrow rotate left anti normal


///test input::
wait 10.
until false{
	print terminal:input.
}