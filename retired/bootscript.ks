//generalized bootscript.

//version 1.00 : beta.
//version 2.00 : improved storage consumption.
//               {removed hasfile function and replaced with builting exists(pat,file)}


//todo: version 3.00 compile files before downloading if they are large.


function delay{
	set dtime to addons:RT:kscdelay(ship)*3.
	set acctime to 0.
	until acctime >= dtime{
		set start to time:seconds.
		wait until (time:seconds-start) >(dtime- acctime) or not addons:rt:HASCONNECTION(ship).
		set acctime to acctime + time:seconds - start.
	}
}

function Download{//downloads update script from ksc
	parameter filename.
	switch to 1.
	if exists(filename){
		deletepath(filename).
	}
	delay().
	if exists("0:/"+filename){
		copypath("0:/"+filename,"").
	}
}
function upload{
	parameter filename.
	delay().
	if exists("0:/"+filename){
		deletepath("0:/"+filename).
	}
	if exists(filename){
		copypath(filename,"0:/").
	}
}
function require{
	parameter filename.
	if not exists(filename){
		if exists("0:/library/"+filename){
			delay().
			copypath("0:/library/"+filename,"").
		}
		else{
			download(filename).
		}
	}
}
function libreq{//library require
	parameter filename.
	require(filename).
	if exists(filename){
		runoncepath(filename).
	}
}

set startupfile to SHIP:name+".startup.ks". 
//startup file instruction (like limiting electric loss and connecting to a specific point 
//and looking at a specific point) must wait 10 and reboot to limit useless instructions.

set updatescript to ship:name+".update.ks".


if addons:rt:HASCONNECTION(ship){
	if exists("0:/"+updatescript){
		Download(updatescript).
		runpath(updatescript).
		deletepath(updatescript).
		if addons:rt:HASCONNECTION(ship){
			deletepath("0:/"+updatescript).
		}
		reboot.
	}
}

IF exists(startupfile) {
	Runpath(startupfile).
} 
ELSE {
	WAIT UNTIL ADDONS:RT:HASCONNECTION(SHIP).
	WAIT 10.

	REBOOT.
}