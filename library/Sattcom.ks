//to add : panicmode: try to connect us 

function allantennas{
	declare local ls1 is ship:partsdubbedpattern("Antenna").
	declare local ls2 is ship:partsdubbedpattern("Dish").
	for element in ls2{
		ls1:add(element).
	}
	return ls1.
} //listing all antennas in one list.
function highlightantenna{
	parameter part.
	parameter color.
	parameter highlight_delay.
	local h is highlight(part,color).
	wait highlight_delay.
	set h:enabled to False.
}

//actual functions here:
//----------------------
function LOGConnectionINFO{
	local logsfile is ship:name+".logs.txt".
	if exists("1:/"+logsfile){
		deletepath("1:/"+logsfile).
	}
	//delete the previous logsfile in order to overwrite it.
	from {local x is 0.} UNTIL x = allantennas():length   STEP {set x to x+1.}DO{
		local antenna is allantennas()[x].
		log "----------------------------------" to logsfile.
		log (x+1)+": "+antenna:name to logsfile.
		local m is antenna:getmodule("ModuleRTAntenna").
		log "status: "+m:getfield("Status") to logsfile.
		log "Target: "+m:getfield("Target") to logsfile.
		log "" to logsfile.
	}
} //logs each antenna index,name,status and target to a text file.

function settarget{
	parameter index.
	parameter tgt.
	local p is allantennas()[index-1].
	local m is p:getmodule("ModuleRTAntenna").
	m:setfield("Target",tgt).
	highlightantenna(p,rgba(0.2,0,1,5),2).
}

function activate{
	parameter index.
	local p is allantennas()[index-1].
	local m is p:getmodule("ModuleRTAntenna").
	if m:getfield("Status")="Off"{
		m:doevent("activate").
		highlightantenna(p,rgba(0,0.5,1,5),5).
	}
}
function activate_all{
	from {local x is 1.} UNTIL x = allantennas():length  STEP {set x to x+1.}DO{
		activate(x).
	}
}

function deactivate{
	parameter index.
	local p is allantennas()[index-1].
	local m is p:getmodule("ModuleRTAntenna").
	if m:getfield("Status")="Operational" or m:getfield("Status")= "Connected"{
		m:doevent("Deactivate").
		highlightantenna(p,rgba(1,0,0,5),5).
	}
}

function deactivate_all{
	from {local x is 1.} UNTIL x = allantennas():length  STEP {set x to x+1.}DO{
		deactivate(x).
	}
}
