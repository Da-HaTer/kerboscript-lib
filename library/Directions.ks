//primal directions for ksp navigation.
set nor to{
	set normalvec to vcrs(ship:velocity:orbit,-body:position).
	set normalvec to normalvec:direction.
	return normalvec.
}.
set rad to{
	set normalvec to vcrs(ship:velocity:orbit,-body:position).
	set radialVec to vcrs(-ship:velocity:orbit, normalvec):direction.
	return radialVec. 
}.
set antinor to{
	set anti_normalvec to vcrs(ship:velocity:orbit, body:position).
	set anti_normalvec to anti_normalvec:direction.
	return anti_normalvec.
}.
set antirad to{
	set normalvec to vcrs(ship:velocity:orbit,-body:position).
	set anti_raidalVec to vcrs(ship:velocity:orbit, normalvec):direction.
	return anti_raidalVec.
}.
set tgt_retro to{
	set target_retrograde_vec to target:velocity:orbit -ship:velocity:orbit.
	return target_retrograde_vec:direction.
}.
set tgt_prog to{
	set target_prograde_vec to ship:velocity:orbit - target:velocity:orbit.
	return target_prograde_vec:direction.
}.
set tgt to{
	set targetvec to target:position - ship:position.
	return targetvec:direction.
}.
set antitgt to{
	set antitargetvec to ship:position - target:position.
	return antitargetvec:direction.
}.