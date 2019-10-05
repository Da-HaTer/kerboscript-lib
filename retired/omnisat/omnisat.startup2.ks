//omnisat startup v2
libreq("Directions.ks").
deletepath("Orbit.ks").
deletepath("kos.lib.ks").
deletepath("Hohmann.Transfer.ks").
deletepath("omnisat.update.ks").
lock steering to rad().
wait 10.
reboot.