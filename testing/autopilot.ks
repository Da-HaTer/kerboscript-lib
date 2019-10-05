//Autopilot
function compass_vector{
	parameter vec.
	local v_ is vec:normalized. //unit pointing vector
	local k1 is vdot(v_,north:vector). //vdot with north vector
	local k2 is vdot(v_,north+r(0,-90,0):vector). //vdot with east vector
	return k1*north:vector+k2*(north+r(0,-90,0):vector).
}//vector on the plane normal to "down" vector
function roll_ctrl{
	parameter input_angle is 0. // -R +L
	if not(defined roll_pid){
		global roll_pid is pidloop(1e-5,1e-7,1e-4,-1,1).
		set roll_pid:setpoint to 0.
		global roll_output is ship:control:roll.
	}
	if input_angle<=0 set roll_angle to vang(-ship:facing:starvector,compass_vector(-ship:facing:starvector))+input_angle.
	else set roll_angle to vang(ship:facing:starvector,compass_vector(ship:facing:starvector))-input_angle.
	set ship:control:roll to roll_output.
	if vang(up:vector,ship:facing:starvector) <90+input_angle set roll_input to -roll_angle.
	else set roll_input to roll_angle.
	set roll_output to roll_output+roll_pid:update(time:seconds,roll_input).
	return roll_output.
}// put to testing
function pitch_ctrl{
	parameter input_angle is 5.
	if not(defined pitch_pid){
		global pitch_pid is pidloop(1e-3,1e-7,1e-6,-1,1).//
		set pitch_pid:setpoint to 0.
		if ship:control:pitch <>0 global pitch_output is ship:control:pitch.
		else global pitch_output is 0.3.
	}
	local lock pitch_angle to vang(ship:facing:vector,compass_vector(ship:facing:vector)).
	set ship:control:pitch to pitch_output.
	if vang(ship:facing:vector,up:vector)>90-input_angle set pitch_input to -pitch_angle. 
	else set pitch_input to pitch_angle.
	set pitch_output to pitch_output+pitch_pid:update(time:seconds,pitch_input).
	return pitch_output.
}
function ish{
	parameter a.
	parameter b.
	parameter ishyness.
	
	return a+ishyness>b and a- ishyness <b.
}
local main is {
	set runmode to "settle_up".
	local lock pitch_error to abs(vang(ship:facing:vector,compass_vector(ship:facing:vector))).
	sas off.
	clearscreen.
	on abort{
		set ship:control:neutralize to true.
		sas on.
		reboot.
		preserve.
	}
	until false{
		if runmode= "settle_up"{
			roll_ctrl().
			if not (defined init_time) set init_time to time:seconds.
			pitch_ctrl().
			if time:seconds- init_time >15{
				if ish(pitch_pid:pterm,0,0.1) and ish(roll_pid:pterm,0,0.1){
					set runmode to "orient".
				}
			}
		}
		else if runmode="level_up"{
			local altctrl is pidloop(1e-3,1e-3,1e-4,-10,20).
			set altctrl:setpoint to 0.
			local altoutput is 0.
			until ish(verticalspeed ,0,1) and ish(altitude,5000,10){
				set altoutput to altoutput+altctrl:update(time:seconds,5000-altitude ).
				print altoutput at (0,3).
				pitch_ctrl(altoutput).
				roll_ctrl().
			}
			set runmode to "orient".
		}//useful to reach a certain atlitude
		else if runmode="orient"{
			set haswaypoint to false.
			for wp in allwaypoints(){
				global orient_vector is wp:position.
			}
			///imrpove )
			set orient_vector to latlng(-0.0972030237317085,-74.5576019287109):position.
			//runway
			if orient_vector:mag <=10000{
				runpath("1:/Science.ks").
			}
			if vdot(compass_vector(orient_vector),compass_vector(ship:facing:starvector))<=0 {
				//if roll_input <0 set input_angle to 5.
				set input_angle to min(60,max(0,vang(compass_vector(orient_vector),compass_vector(ship:facing:vector)))).//gradiual funnction
			}
			else {
				//if roll_input >0 set input_angle to -5.
				set input_angle to max(-60,min(0,-vang(compass_vector(orient_vector),compass_vector(ship:facing:vector)))).
			}
			roll_ctrl(input_angle).
			if not ish(altitude,5000,100) and altitude <5000 set pitch_val to 5.
			if not ish(altitude,5000,100) and altitude >5000 set pitch_val to -2.
			else set pitch_val to 1.
			if pitch_error>=5 or verticalspeed <=-20 or input_angle <> 0 pitch_ctrl(pitch_val).
		}
		print runmode at (0,5).
		wait 0.001.
	}
}
main()