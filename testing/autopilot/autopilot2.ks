
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
		global roll_pid is pidloop(5e-5,1e-7,1e-4,-1,1).
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
		global pitch_pid is pidloop(1e-3,1e-4,1e-6,-1,1).//
		set pitch_pid:setpoint to 0.
		//if ship:control:pitch <>0 
		global pitch_output is ship:control:pitch.
		//else global pitch_output is 0.3.
	}
	local lock pitch_angle to vang(ship:facing:vector,relative_radar_vector(ship:facing:vector)).
	set ship:control:pitch to pitch_output.
	if vang(ship:facing:vector,up:vector)>90-input_angle set pitch_input to -pitch_angle. 
	else set pitch_input to pitch_angle.
	set pitch_output to pitch_output+pitch_pid:update(time:seconds,pitch_input).
	return pitch_output.
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


function vector_seek{
    //meant to be run inside a loop
    parameter paramvector.
    parameter priority is 1.//1 no yaw //2 lock roll to 0 and rely on yaw(risky)
    parameter maxrollangle is 60.
    parameter maxpitchangle is 45.
    
    sas off.

    set target_compass to relative_radar_vector(paramvector).
    
    set forward to relative_radar_vector(ship:facing:vector).
    set rightvec to vcrs(forward,up:vector).

    set absolute_bank_angle to vang(forward,target_compass).
    set absolute_Pitch_angle to vang(target_compass,paramvector).
    
    if vdot(rightvec,target_compass)>0 set desired_roll_angle to min(maxrollangle,absolute_bank_angle).
    else set desired_roll_angle to max(-maxrollangle,-absolute_bank_angle). 

    if vdot(up:vector,paramvector)>=0 set desired_pitch_angle to min(maxpitchangle,absolute_Pitch_angle).
    else set desired_pitch_angle to max(-maxpitchangle,-absolute_Pitch_angle).

    print "pitch "+desired_pitch_angle+" roll "+desired_roll_angle at (0,5).
    if vang(target_compass,forward) <=10 pitch_ctrl(desired_pitch_angle).
    else pitch_ctrl(0).
    if priority=1{ 
    	roll_ctrl(desired_roll_angle).
    }

    else if priority =2{
    	roll_ctrl(0).
    	yaw_ctrl(target_compass).
    }
}
///to be tested
clearscreen.

sas off.
until false{
	vector_seek(latlng(-0.0972030237317085,-74.5576019287109):position).
	wait 0.001.
}

//////////////////////
function GVEC{
	parameter vec.//vector end
	parameter color is rgb(random(),random(),random()).
	parameter name is "N/A".
	return vecdraw(
		v(0,0,0),
		vec,
		color,
		name,
		1,
		true,
		0.5
	).
}	
set tgt_vec to relative_radar_vector(srfprograde:vector).
clearvecdraws().
when true then{
	if terminal:input:getchar=0 set tgt_vec to relative_radar_vector(srfprograde:vector).
	else if terminal:input:getchar=4 set tgt_vec to (tgt_vec:direction+r(-5,0,0)):vector.
	else if terminal:input:getchar=6 set tgt_vec to (tgt_vec:direction+r(5,0,0)):vector.
	else if terminal:input:getchar=5 set tgt_vec to (tgt_vec:direction+r(0,5,0)):vector.
	else if terminal:input:getchar=8 set tgt_vec to (tgt_vec:direction+r(0,-5,0)):vector.
	//terminal:input:clear().
	preserve.
}
set visual to gvec(tgt_vec*10,red,"aim vector").
set visual:vecupdater to {return tgt_vec*10.}.
