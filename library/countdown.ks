//Mission Timer script.
//spaceX style timer bar.
//fix delay. // fixed 
// line1:mission name line2:events with auto refrech line3: resources rest:maybe orbit info

parameter timer.
function countdown{
	parameter timer.//local param
    If alt:radar < 70 and verticalspeed > -1 and verticalspeed < 1 { //asume we are on the launchpad
		print "counting down".
		lock throttle to 1.
		FROM {local T is timer.} UNTIL T = 0 STEP {set T to T-1.} DO {
				if T>9 {
                    print ("  T-"+"00:00:"+T) at (0,30).
                }
                else {
                    print ("  T-"+"00:00:0"+T) at (0,30).
                }wait 1.
		}
	print "liftoff". stage.

                	}
}

function info{
	parameter timer.// countodwn timer 
	countdown(timer).
    when true then{
        seconds().
        minutes().
        hours().
        print ("  T+ "+h+":"+m+":"+s) at (0,30).
        print ("SPEED:"+round((sqrt(groundspeed^2+verticalspeed^2))*3.6,2)+" Km/h") at (0,31).
        print ("ALTITUDE:"+round((alt:radar)/1000,2)+" Km") at (21,31).
        preserve.
    }
    function seconds{
        if mod(missiontime,60) > 9{ 
            global s is floor(mod(missiontime,60)).
        }
        else {
            global s is ("0"+ floor(mod(missiontime,60))).
        }
    }
    function minutes{
        if (mod(missiontime,3600) / 60) > 9{
            global m is floor(mod(missiontime,3600) / 60).
        }
        else{
            global m is ("0"+floor(mod(missiontime,3600) / 60)).
        }
    }   
    function hours{
        if (missiontime / 3600) > 9 {
            global h is floor(missiontime / 3600).
        }
        else {
            global h is ("0"+floor(missiontime / 3600)).
        }
    }
}
info(timer).