CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
SET TERMINAL:WIDTH to 52. 
SET TERMINAL:HEIGHT to 35.

if alt:radar < 50 {
	copypath ("0:/KOStok-1-launch.ks", "").
	copypath("0:/KOStok-1-abort.ks", "").
	print "capacity: "+Volume(1):CAPACITY.
	print "freespace: "+Volume(1):FREESPACE.
	wait 5.
	run "KOStok-1-launch"(90).

}else {
	run "KOStok-1-abort".
}