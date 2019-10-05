			//suicide burn v1
			//-----------------
			//suicide_burn v2: 
			//remove groundspeed from total speed to improve time (beware of sharp attack angle)

			//suicide_burn v2.5:
			//hoverscript with pid

			//suicide_burn v3:
			//guided landing

			//d=v^2/2*a
			parameter ship_height is 12.
			clearscreen.
			if hastarget set tgt to latlng(target:latitude,target:longitude).	
			else global tgt is latlng(-0.0972030237317085,-74.5576019287109). //launcpad
			//else global tgt is latlng(-0.0978078842163086,-74.6201782226563). //launcpad
			global lock ground_distance to (tgt:position-latlng(latitude ,longitude ):position):mag .
			lock g to (body:mass*constant:g)/(body:radius+alt:radar )^2.
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
				sas off.
				rcs on.
				if vdot(head_for(tgt,90):normalized,srfprograde:vector:normalized) <0 and not (ground_distance<=500) boostback().
				lock steering to safe_retrograde() .
			}
			function suicide_burn{
				lock tval to deceleration_time() /time_to_impact().
				wait until time_to_impact() <= deceleration_time().lock throttle to tval. gear on.
				wait until realaltitude <=2 or verticalspeed >-1.
				wait 0.5. lock throttle to 0. set ship:control:pilotmainthrottle to 0.
			}
			function safe_retrograde{
				//-74.5576019287109 long
				//-0.0972030237317085 lat
				local angle is 50.
				if throttle =0 {
						if ground_distance >=20{
							return head_for(tgt,-70)-tgt:position:normalized+10*(-tgt:position:normalized-srfretrograde:vector).
							}
						else return -tgt:position:normalized+10*(-tgt:position:normalized-srfretrograde:vector).
					}
					//when engines are on
					if not (ground_distance >500 or realaltitude <35 or ground_distance<=5 or vang(srfretrograde:vector,up:vector)>20){
						set pid to pidloop(0.1,0.1,2).
						set pid:setpoint to 0. 
						until alt:radar <10 or vang(srfretrograde:vector,up:vector)>30{
							set angle to angle+pid:update(time:seconds,ground_distance).
							return head_for(tgt,angle)*2+srfretrograde:vector.
						}
					}

					return srfretrograde.
					}
			function deceleration_time{
				//t=v/a
				//local v is abs(ship:verticalspeed).
				if maxacc <>0 return v/maxacc.
			}
			function boostback{
				
				if verticalspeed >2 set impactime to eta:apoapsis+impacttime(apoapsis).
				else set impactime to impacttime(alt:radar).
				local lock angle to max(45,min(90,(ground_distance/50))).
				when true then {print angle at (0,8). preserve.}
				lock steering to head_for(tgt,max(40,angle)).
				wait until colinear(head_for(tgt,max(40,angle)),5).
				lock throttle to 1.
				wait until vdot(head_for(tgt,90):normalized,srfprograde:vector:normalized) >0 .
				wait until groundspeed *impactime >=sqrt(abs(tgt:position:mag^2-realaltitude^2))*tgt:position:mag/realaltitude.
				lock throttle to 0.
			}
			function time_to_impact{
				//d=1/2at^2+v0t
				local d is realaltitude.
				return (sqrt(v^2+2*g*d)-v)/g.
			}
			global colinear is {
				parameter v1.
				parameter max_error_angle is 10.
				parameter v2 is ship:facing:vector.
				return vang(v1,v2) <=max_error_angle.
			}.
			function impacttime{
					//d=1/2at^2+v0t
				parameter d.
				local v_ is abs(ship:verticalspeed).
				return (sqrt(v_^2+2*g*alt:radar)-v_)/g.
				}
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
			lock steering  to up.
			wait 5.
		//lp
		//-74.5576019287109 long
		//-0.0972030237317085 lat
		//almost works
		//vab
		//-0.0978078842163086
		//-74.6201782226563

//to avoid launchin straight up and wasting fuel implement a pid loop that avoids increasing in apoapsis but pitches