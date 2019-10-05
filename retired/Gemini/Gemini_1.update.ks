libreq("Sattcom.ks").
require("Directions.ks").
require("Ascent.ks").
require("Science.ks").
run Ascent(15,60,75000).
deletepath("Ascent.ks").
toggle gear.
libreq("Sattcom.ks").
activate(1).
wait 5.
Download(startupfile).