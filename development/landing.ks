function GVEC{
    parameter vec.//vector end
    parameter name is "N/A".
    parameter color is rgb(random()*3,random()*3,random()*3).
    return vecdraw(
        v(0,0,0),
        vec,
        color,
        name,
        1,
        true,
        0.5
    ).
} //dra
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
        global pitch_pid is pidloop(1e-3,1e-7,1e-5,-1,1).//
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
        global yaw_pid is pidloop(1e-7,1e-7,1e-7,-0.2,0.2).//
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
    parameter maxpitchangle is 30.
    
    sas off.

    set target_compass to relative_radar_vector(paramvector).
    
    set forward to relative_radar_vector(ship:facing:vector).
    set rightvec to vcrs(forward,up:vector).

    set absolute_bank_angle to vang(forward,target_compass).
    set absolute_Pitch_angle to vang(target_compass,paramvector).
    
    if vdot(rightvec,target_compass)>0 set desired_roll_angle to min(maxrollangle,absolute_bank_angle*1.2).
    else set desired_roll_angle to max(-maxrollangle,-absolute_bank_angle*1.2). 

    if vdot(up:vector,paramvector)>=0 set desired_pitch_angle to min(maxpitchangle,absolute_Pitch_angle).
    else set desired_pitch_angle to max(-maxpitchangle,-absolute_Pitch_angle).

    print "pitch "+desired_pitch_angle+" roll "+desired_roll_angle at (0,6).
    if vang(target_compass,forward) <=35 pitch_ctrl(desired_pitch_angle).
    else pitch_ctrl(0).
    if priority=1{ 
        roll_ctrl(desired_roll_angle).
    }

    else if priority =2{
        roll_ctrl(0).
        yaw_ctrl(target_compass).
    }
}

lock rw to latlng(-0.048515,-74.7155075073242):position.
//west side
lock re to latlng(-0.050117,-74.501998989013672):position.
//East side
set rn to vCrs(re-rw,up:vector).
//north to runway

on abort{
    clearvecdraws().
    set ship:control:neutralize to true.
    unlock throttle .
    sas on.
    reboot.
    preserve.
}
clearscreen.
sas off.
set runmode to 0.
until airspeed<=1 and ish(verticalSpeed,0,0.1){
    if runmode=0{
        print 0 at (0,5).
        if alt:radar <=500 and ship:availablethrust >0{
            lock throttle to 1.
            gear off. brakes off.
            until alt:radar >=1000{
                pitch_ctrl(15).
                roll_ctrl(0).
            }
        }
        else abort.
        unlock throttle .
        set runmode to 1.
    }
    else if runmode=1{
        if rw:mag <=re:mag{
            lock rvec to rw.
            lock rvec2 to re.
            set rw_dir to rw-re.
        }
        else{
            lock rvec to re.
            lock rvec2 to rw.
            set rw_dir to re-rw.
            
        }
        //direction from runway to fake point 
        if altitude <=1500 lock pt1 to rvec+5*rw_dir+up:vector*(1200).//(max(1000,altitude-50)).
        else lock pt1 to rvec+5*rw_dir+up:vector*(altitude -700).//(max(1000,altitude-50)).
        //first virtual point
        if vdot((pt1- rvec):normalized,pt1:normalized) >=0.1{
            //should make u turn
            ///wrong possibily
            if vdot(rn,rvec) >1 lock pt2 to pt1-rn:normalized*4000.
            else lock pt2 to pt1+rn:normalized*4000.
        }
        else lock pt2 to pt1+rw_dir:normalized.
        ///selection of pt1 & pt2
        clearvecdraws().
        set v1 to GVEC(pt1,"pt1").
        set v1:vecupdater to {return pt1.}.
        set v2 to GVEC(pt2,"pt2").
        set v2:vecupdater to {return pt2.}.
        set v3 to GVEC(rvec,"rw").
            set v3:vecupdater to {return rvec.}.
    
        print 1 at (0,5).
        until pt2:mag <=1500 or (pt2-pt1):mag <=100{
            vector_seek(pt2).
        }
        set runmode to 2.
    }
    else if runmode=2{
        print 2 at (0,5).
        until pt1:mag <=2000{
            if altitude >=20_000 lock steering to pt1.
            else vector_seek(pt1).
        }
        lock rvec1 to rvec-(rvec2-rvec):normalized*1000+up:vector*100.
        //margin
        set turnaxis to vcrs(relative_radar_vector(rvec1-pt1),up:vector).
        lock turnvect to (vdot(turnaxis,pt1)*turnaxis):normalized.
        lock vec_dir to rvec1:normalized*30+turnvect*0.7.
        set v4 to GVEC(vec_dir,"need to follow").
        set v4:vecupdater to {return vec_dir.}.
        until rvec1:mag <=500{
            vector_seek(vec_dir).
        }
        gear on.
        set runmode to 3.
    }
    else if runmode=3{
        print 3 at (0,5).
        brakes on.
        if max(-10,min(1-1.085^(altitude -150),5))<>0 set descent to relative_radar_vector(2*rvec2-rvec)+tan(max(-10,min(1-1.085^(altitude -150),5)))*up:vector.
        //set descent to rvec2+up:vector*(min(alt:radar*2,30)).
        vector_seek(descent).
        //pitch_ctrl(max(-10,1-1.085^(2*(alt:radar-20)))).
        //roll_ctrl(0).

        if rvec2:mag < rvec:mag and status<>"landed"{
            set ship:control:yaw to 0.
            set runmode to 0.
        }
        else if status="landed" set runmode to 4.
    }
    else if runmode=4{
        print 4 at (0,5).
        yaw_ctrl(rvec2).

    }
}
abort.
wait 0.5.