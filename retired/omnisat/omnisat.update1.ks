//omnisat update #1
Download(startupfile).
require("Ascent.ks").
libreq("Sattcom").
libreq("Directions.ks").
libreq("Orbit.ks").
libreq("kos.lib.ks").
run Ascent(15,90,75000).
deletepath("Ascent.ks").
//launches to low kerbin orbit then executes startup.ks frequently.