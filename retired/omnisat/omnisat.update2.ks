//omnisat update #2 

 //if ship can read this it means it has connection
Upload(startupfile).
require("Hohmann.Transfer.ks").
libreq("kos.lib.ks").
libreq("Orbit.ks").
libreq("Sattcom.ks").
Set previoussatt to{
	local currentmodel is ship:name[ship:name:length-1]:tonumber().// 1 to 4
	return slice(ship:name,0,-1)+(mod(currentmodel+2,4)+1).// magic python
}.


list targets in allvessels.
set ship_name to{
	local e is false.
	for v in range(5){
		set v to v+1.
		local name is ship:name+v.
		for vess in allvessels{
			if name = vess:name {
				set e to true.
			}
		}
		if not e { return ship:name+v.} 
		set e to false.
	}
}.//automatically determin the ship's name
set shipname to ship_name(). //Obtain our satt version
Download(shipname+".startup.ks").
if ship:name <="omnisat1"{// meaning if we are OmniSatt1
	runpath ("hohmann.transfer.ks",0,ship,2_600_000).//be careful not to fall into dark side.
}
else{
	set target to orbitable(previoussatt()).
	runpath("hohmann.transfer.ks",90).
}
panels on.
from {local x is 1.} UNTIL x = 7  STEP {set x to x+1.}DO{
	activate(x).
	wait 3.
}
if not ship:name <="omnisat1"{
	settarget(1,previoussatt()).
}
settarget(2,"Mission Control").
settarget(3,"Active-Vessel").
settarget(4,"Mun").
settarget(6,"Minmus").
LOGConnectionINFO().
Upload("omnisat.update.ks").