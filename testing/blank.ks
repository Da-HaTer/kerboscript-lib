//read/write to disk

function writemode{
    parameter runmode.
    local drive is "drive.ks".
    log "" to drive.
    deletepath("1:/"+drive).
    log "set runmode to "+runmode+"." to drive.
}
function readmode{
    local drive is "drive.ks".
    log "" to drive.
    runpath("1:/"+drive).
}
set runmode to 0.
readmode().
if runmode=0{
    writemode(1).
    reboot.// either make this a startupfile or bootfile
}
print runmode=1.

folder shipname_mission{
	folder shipname.update.ks
	for file in folder{
		run file X crash{
			recover from crash 
			continue runmode
		}
		delete file 
		reboot
	}
	else run startupfile
	
}

luna 2:
runmode 1: window and launch
download orbit koslib bricbeta sattcom
runmode 2: getting to mun delete previous modules but sattcom and download science
runmode 3: run science every 30 seconds and check connection every 2 minutes

can't rely on update
make update startup

