//gemini 1 startup
libreq("Directions.ks").
libreq("Science.ks").
libreq("BRIC_beta.ks").
if altitude >70000 {
	lock steering to nor().
	run Science.
}
wait 2.
reboot.