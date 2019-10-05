SET V0 to GetVoice(0).
SET V0:VOLUME TO 1.
SET V0:WAVE to "square".
SET V0:ATTACK to 0.2.
SET V0:DECAY to 0.1.
SET V0:SUSTAIN to 0.3. // 70% volume while sustaining.
SET V0:RELEASE to 0.2. // takes half a second to fade out.

function going2crush{
	if verticalspeed <=-50 or (alt:radar <= 100 and verticalspeed <10 and airspeed >= 120) return true.
	return false.
}
when true then {
	v0:play(note(400,1)).
	HUDTEXT( "PULL UP!",
         0.6,
         6,
         50,
         rgba(1,0.5,0.5,0.5),
         false).
	wait 0.5.
	preserve.
}
wait until false.




