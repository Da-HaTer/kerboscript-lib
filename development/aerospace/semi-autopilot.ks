
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
//PID_init(0.005, 0.001, 0.0001, -1, 1).
//(1e-3,1e-7,1e-6,-1,1)
function pitch_ctrl{
	parameter input_angle.
	if not(defined pitch_pid){
		global pitch_pid is pidloop(5e-4,1e-7,1e-6, -1, 1).//
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
}//lock pitch to a given angle

clearscreen.
local input_angle is 0.
local pitch_angle is 5.
local should_levelup is true.
local lock pitch_error to abs(vang(ship:facing:vector,relative_radar_vector(ship:facing:vector))).
local is_settled is false.
on abort{
	set ship:control:neutralize to true.
	sas on.
	reboot.
	preserve.
}
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
//when true then{
//	if terminal:input:getchar=0{
//		set input_angle to 0.
//		set pitch_angle to 5.
//	}
//	else if terminal:input:getchar=4 {
//		if input_angle<=55 set input_angle to input_angle +5.
//	}
//	else if terminal:input:getchar=6 {
//		if input_angle >=-55 set input_angle to input_angle -5.
//	}
//	else if terminal:input:getchar=5 {
//		if pitch_angle >=-40 set pitch_angle to pitch_angle -5.
//	}
//	else if terminal:input:getchar=8 {
//		if pitch_angle<=40 set pitch_angle to pitch_angle +5.
//	}
//	//terminal:input:clear().
//	preserve.
//}
//abort autopilot operations

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
	pitch_ctrl(pitch_angle).
	if time:seconds- init_time >15{
		if ish(pitch_pid:pterm,0,0.1) and ish(roll_pid:pterm,0,0.1){
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
	roll_ctrl(input_angle).
	if pitch_error>=5 or verticalspeed <=-20 or input_angle <> 0 level_up().
	wait 0.001.
}
// main instructions to hold steering
