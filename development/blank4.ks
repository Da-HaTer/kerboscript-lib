	local tgt is latlng(-0.0972030237317085,-74.5576019287109).
	set config:ipu to 2000.
	function boostback{
		rcs on.
		lock throttle to 0.
		clearVecDraws().
		// local lock impactime to impact_time().
		local future_state is integrate_trajectory(1).
		// lock steering to tgt_vec.
		local lock current_landing_spot to future_state[0]:position.
		local lock impactime to future_state[1].
		print ("impactime"+impactime).
		local lock tgt_future_pos to latlng(tgt:lat,tgt:lng+impactime*360/21549.425):position.
		local gvec is vecdraw(v(0,0,0),current_landing_spot,red,"current",1,true,0.1).
		set gvec:vectorupdater to {return current_landing_spot.}.

		local tvec is vecdraw(v(0,0,0),tgt_future_pos,red,"target",1,true,0.1).
		set tvec:vectorupdater to {return tgt_future_pos.}.
		
		local lock differential to (tgt_future_pos-current_landing_spot). // differential vector ( where we should go )
		// set stillvec to head_for(differential,5). 
		lock steering to differential.
		
		wait until colinear(head_for(differential,5),15). lock throttle to 1.
		set  d0 to 300_000. // arbitrarily big number that should trigger conditional loop
		until (d0 < differential:mag){ // this part shocking
			print ("detlad: "+"0000000000") at (0,3).
			print ("detlad: "+differential:mag) at (0,3).
			set d0 to differential:mag.
		}
		// clearVecDraws().
		// wait until vdot(relative_radar_vector(tgt_future_pos:position),srfprograde:vector:normalized) >0 . // heading towards target
		// wait until downrange(integrate_trajectory(1))>=downrange(tgt_future_pos). //until above ksc marginal error 
		//increase 5000 if undershooting (5km)
		lock throttle to 0.
		lock steering to srfRetrograde.
		set predicted_spot to current_landing_spot.
		set gvec:vectorupdater to {return predicted_spot:position.}.
		wait until altitude<5000.		
	}


	function downrange{ //unused here
		parameter p2.
		parameter p1 is ship:geoposition.
		return arcCos(sin(90-p1:lat)*sin(90-p2:lat)*cos(p2:lng-p1:lng)+cos(90-p1:lat)*cos(90-p2:lat))/360*2*600_000*constant:pi. // distance
	}

	// function lng{ //calculates angles in better range
	// 		parameter x. // longitude / latitude
	// 		return mod(x+3600,360).
	// 	}
	function impact_time {
		//d=1/2at^2+v0t
		local t is 0.
		if verticalspeed>2 set t to eta:apoapsis.
		parameter d is abs(alt:radar).//-Vessel_height()).
		parameter v is abs(verticalspeed ).
		local g is gacc(ship:body,d).
		return t+(sqrt(v^2+2*g*d)-v)/g.
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

	function head_for{///notice: replaced paramter from coordinates to vector (check all instances)
		parameter param_vec.
		parameter angle_of_attack.
		if angle_of_attack=0{
			return relative_radar_vector(param_vec).
		}
		else{
		local lock relative_vec to relative_radar_vector(param_vec)/tan(angle_of_attack).
		local lock return_vec to relative_vec+up:vector.
		return return_vec.}
		// locking steering to a diretion of 1+1=>45deg
	}
	function mu{
		parameter bod is body.
		return constant:G*bod:mass.
	}
	function gacc{
		parameter bod is body.
		parameter height is 0.
		return mu(bod)/(bod:radius+ height )^2.
	}
	function integrate_trajectory{
		parameter dt.
		// clearVecDraws().
		local R0 is -kerbin:position. //Ur0
		local v0 is ship:velocity:orbit.//V0
		//local Th0 is max(1,ship:availablethrust/ship:mass).
		//local a0 is TH0*ship:facing:vector-gacc(kerbin,R0:mag)*up:vector.
		local a0 is (-(kerbin:mass*constant:G)/(R0:mag)^2)*R0:normalized.
		
		local R is R0.
		local v is v(0,0,0).
		local a is v.

		local vtime is 0. //virtual loop time
		until (R:mag <=kerbin:radius+15_000){
			set vtime to vtime+dt. //cumulative time 
			
			set R to R0+v0*dt.
			set v to v0+a0*dt.
			//set TH to vex/((vex/Th0)-dt).//thrust 
			set a to (-(kerbin:mass*constant:G)/(R0:mag)^2)*R:normalized.
			
			//raw vector to spherical coordinates
			// vecdraw(R0+kerbin:position,R-R0,red,"",1,true,0.1).
			
			set R0 to R.
			set V0 to v.
			// set TH0 to TH.
			SET a0 To a.
		}

		local x is Body:GEOPOSITIONOF(kerbin:position+R0).   
		return list(latlng(x:lat,x:lng-vtime*360/21_549.425),vtime).
	}
	clearScreen.
	lock targetPitch to min(90,90*0.99996^altitude).
	set randir to 90.
	lock steering to heading(randir,targetpitch).
	lock throttle to 1.
	gear off.
	stage.
	wait until apoapsis>=50_000.
	set kuniverse:timewarp:rate to 1.
	stage.
	boostback().
	clearVecDraws().


	// fxied issues:
		// if target pos is exactly under : 
		// -lock steering to wrong direction 
		// -premature stop throttle condition
		///fixed 
		//(differential position vector)

	//issues:
	
	// add a flip maneuver (kos handicap)
	//inaccurate landing spot 
	// engine cut off latency
	///test landing and target location predictions 
	//wrong trajectoy are we no accounting for current trajectory landing spot + rotation ??????
	
	//predicted landing site position very advanced (land in sea) 
	//won't stop when passt landing site
	//faulty impact time ??


	//conclusion: boostback() is overpowered by iterations.