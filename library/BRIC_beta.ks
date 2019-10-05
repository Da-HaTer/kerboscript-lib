//BRIC BETA ( Basic Rocket Internal Calculations)
@lazyglobal off.
function mu{
	parameter bod is body.
	return constant:G*bod:mass.
}
function gacc{
	parameter bod is body.
	parameter height is 0.
	return mu(bod)/(bod:radius+ height )^2.
}
global G0 is gacc(kerbin).
local myengines is list().
list engines in myengines. 
function resource_percentage{//informal function
	parameter resource.
	parameter part_ is ship. //could say stage
	for res in part_:resources{
		if res:name =resource{
			return round(res:amount/res:capacity*100,2).
		}
	}
}
global execute_maneuver is{
	//libreq("BRIC_beta.ks").
	if hasnode {
		local maneuver is allnodes[0].//first upcoming node.
		local lock maneuver_eta to maneuver:eta.
		local lock dir to maneuver:deltav.
		local lock dv to dir:mag.
		local maneuver_time is burntime(dv).
		lock steering to dir.
		wait 5.// making sure we point to the node.
		if maneuver_eta > maneuver_time/2{
			warp_to(maneuver_eta- maneuver_time -5).
		}
		wait until maneuver_eta<=maneuver_time/2.
		until dv<=0.05{
			lock throttle to dv/100+0.0001.
			set ship:control:fore to dv+0.1. 
		}
		set ship:control:fore to 0.
		lock throttle to 0.
		unlock throttle .
		remove maneuver.
	}
	else print "no maneuvers were given". 
}.

global circularization is{
	parameter dltav is 0.
	parameter extremum is "apoapsis".
	local last_ecc is 1.
    local step_ is 1000.
    if extremum ="apoapsis" local lock extremum_eta to eta:apoapsis.
    else local lock extremum_eta to eta:periapsis.
    local cirnode is node(0,0,0,0).
    until abs(step_) <1e-3{
        set cirnode to node(time:seconds+extremum_eta,0,0,dltav). //some dv
        add cirnode.
        wait 1e-3.
        if not (cirnode:orbit:Eccentricity<last_ecc){
            set step_ to -(step_/10).   
        }
        set dltav to dltav+step_.
        set last_ecc to cirnode:orbit:Eccentricity.
        remove cirnode.
    }
    return cirnode.
}.
function warp_to{
	parameter time_from_now.
	local warptime is time:seconds+time_from_now.
	wait 5.
	warpto(warptime).
	wait until kuniverse:timewarp:issettled and warp=0.  
}

global orbital_velocity is{
	parameter ves is ship.
	parameter height is (ves:apoapsis+ ves:periapsis)/2.
    return sqrt(mu(ves:body)/(height+ves:body:radius)).
}.

function stage_fuelmass{//stage fuel
	local fuelsum is 0.
	for res in stage:resources{
		if list("SolidFuel","LiquidFuel","Oxidizer"):contains(res:name){
			set fuelsum to fuelsum + (res:amount * res:density).//calculates the mass of the resource given the amount .
		}
	}
	return fuelsum.
}
function ship_fuelmass{//total fuelmass
	return ship:mass-ship:drymass.
}
function activeISP{
	return ISP(1).
}
function totalISP{
	return isp().
}
function ISP{
	parameter active is 0.
	local totalfactor is 0.
	local totisp is 0.
	for eng in myengines{
		local condition is (not eng:flameout).
		if active<>0 set condition to condition and eng:ignition.
		if condition{
			set totalfactor to totalfactor +1.
			set totisp to totisp + eng:vacuumisp.
		}
	}
	if totalfactor <>0 return totisp/totalfactor. //gets average isp of the active engines.
	return 0.
}
function all_stages_deltav{
    local maxstage is stage:number.
    local stages is lexicon().
    from {local x is maxstage.}until x=-1 step{set x to x-1.} do{
        local totalfactor is 0.
        local totisp is 0.
        for engine in myengines{
            if engine:stage=x{
                set totalfactor to totalfactor+1.
                set totisp to totisp+engine:vacuumisp.
            }
        }
        if totalfactor <>0 stages:add(x,totisp/totalfactor).
    }
    local dv_lex is lexicon().
    for n in stages:keys{
        local full_mass is 0.
        local fuel_mass is 0.
        for p in ship:parts{
            if p:stage<=n set full_mass to full_mass+p:mass.
            if p:stage=n-1{
                for res in p:resources{
                    if res:name ="liquidfuel" or res:name="oxidizer"set fuel_mass to fuel_mass+res:amount*res:density.
                }
            }
        }
    dv_lex:add(n,stages[n]*G0*ln(full_mass/(full_mass- fuel_mass))).
    }
    return dv_lex.
}
function total_deltav{
	local total_deltav_ is 0.
	local lex is all_stages_deltav().
	for key in lex:keys{
		set total_deltav_ to total_deltav_+lex[key].
	}
	return total_deltav_.
}
function stage_deltav{
	parameter stagenumber is stage:number.
	local lex is all_stages_deltav().
	for key in lex:keys{
		if key=stagenumber return lex[key].
	}
	return 0.
}
global surface_velocity is{
	return sqrt(verticalspeed ^2+groundspeed ^2).
}.
global impact_time is{
	//d=1/2at^2+v0t
	parameter d is abs(alt:radar-Vessel_height()).
	local v is abs(verticalspeed ).
	local g is gacc(ship:body,d).
	return (sqrt(v^2+2*g*d)-v)/g.
}.

global Vessel_height is{//supppose core is high enough
	local myparts is list().
	list parts in myparts.
	local maxdistance is 0.
	for part in myparts{
		local distance is (core:part:position-part:position):mag. 
		if distance > maxdistance set maxdistance to distance. 
	}
	return ceiling(maxdistance)+1.
} .
function part_highlight{
	parameter part.
	parameter color is rgba(random(),random(),raandom(),1).
	parameter delay_time is 5.
	local h is highlight(part,color).
	wait delay_time.
	set h:enabled to False. 
}
// good cyan color=rgba(0,0.5,1,5)
function twr{
	parameter force.
	parameter active is 1.
	local lock weight to G0*ship:mass.
	return force*active / weight.
}
global available_twr is {return twr(availablethrust).}.
global max_twr is {return twr(maxthrust).}.
global current_twr is {return twr(availablethrust,throttle ).}.
function sleep{
    parameter timer.
    local last_time is time:seconds.
    until false{
        if time:seconds -last_time >= timer{
            return false.
        }
    }
} // can avoid this , kidna useful
global burntime is{
    parameter dv.
    local F is availablethrust .
    local isp is activeISP().
    if F<>0 return G0*ship:mass*isp*(1-constant:E^(-dv/(G0*isp)))/F.
    else return 60.
}.


//toadd 
//algorithm to split each stage from parts:list or maybe can get stage:coupled:enabled module.
//each stage has it's engine count and telemetry, fuel and therefore able to get fuelloss/sec
//and burn time
//more precise delta v and time calculation and 