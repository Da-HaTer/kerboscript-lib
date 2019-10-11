//generalized bootscript.
//2.1 : added download and upload dependancies and connection requirement for them


//version 1.00 : beta.
//version 2.00 : improved storage consumption.
//               {removed hasfile function and replaced with builting exists(pat,file)}

//todo: version 3.00 compile files before downloading if they are large even this file itself.
//include sattcom and include panic mode for connections instead of waiting // beware of ec. {hybernate if not mission critical}
@lazyGlobal off.
clearScreen.
function delay{
	local dtime is addons:RT:kscdelay(ship)*3.
	local acctime is 0.
	until acctime >= dtime{
		local start is time:seconds.
		wait until (time:seconds-start) >(dtime- acctime) or not addons:rt:HASCONNECTION(ship).//
		set acctime to acctime + time:seconds - start.
	}
}
function Download{//downloads update script from ksc
	parameter filename.
	parameter path_from is ("0:/").
	wait until addons:rt:HASCONNECTION(ship).// not quite well as can permutate with next ligne (add panic mode )
	delay().
	if exists(path_from+filename){
		copypath(path_from+filename,"").
	}
}
function upload{
	parameter filename.
	parameter path_to is ("0:/").
	wait until addons:rt:HASCONNECTION(ship).
	delay().
	if exists(filename){
		movePath(filename,path_to).
	}
}
global archive_file is {
	parameter filename.
	parameter projname is shipname .
	local destination_directory is "0:/Archive/"+projname+"/".
	if not exists(destination_directory) and addons:rt:HASCONNECTION(ship) createDir(destination_directory).
	upload(filename,destination_directory).
}.
global require is{
	parameter filename.
	if not exists(filename){
		Download(filename).
		Download(filename,"0:/library/").
	}
}.
global libreq is{//library require
	parameter filename.
	require(filename).
	if exists(filename){
		runoncepath(filename).
	}
}.
global startupfile is SHIP:name+".startup.ks".
global updatescript is ship:name+".update.ks".

if addons:rt:HASCONNECTION(ship){
	if exists("0:/"+updatescript){
		Download(updatescript).
		runpath(updatescript).
		archive_file(updatescript).
		deletepath("0:/"+updatescript).
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