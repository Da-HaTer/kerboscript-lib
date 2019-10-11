global releaseclamps is {
    local clamps is list().
    for p in ship:parts{
        if p:name = "launchclamp1" clamps:add(p).
    }
    for p in clamps{
        local m is p:getmodule("launchclamp").
        m:doevent("release clamp").
    }
}.

stage.
releaseclamps().
		
wait until (altitude >=4000 and 
		altitude <=11000 and
		abs(verticalspeed ) >=60 and 
		abs(verticalspeed ) <=210).
//testconditions
print "test conditions met".
until stage:number= 0 stage.
