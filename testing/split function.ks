// split function
// <aaaaaaaaaaaaaa><aaaaaaaaaaaaaaaa><aaaaaaaaaaaaaa><aaaaaaaaaaaaa

parameter data.
parameter split_parameter.
local li is list().//in case data is only readable.
local local_li is list().
for element in data{
    if split_parameter(element)
    local split is list().
    // how data is read ???
}

local should_split is{

}.

// works for 45 latitude (hardcoded)
function tgt_eta{
    parameter tgt_inc is false.
    parameter tgt_lan is false.
    if hasTarget{
        set tgt_inc to target:obt:inclination.
        set tgt_lan to target:obt:lan.
    }
    function lng{ //calculates angles in better range
        parameter x. // longitude / latitude
        return mod(x+360,360).
    }
    lock site_lng to lng(longitude+body:rotationangle) . // +-
    set site_angv to body:angularVel:mag*cos(latitude)*body:radius.// rotation angle at lauch site
    //set tgt_lat_max to cos(constant:pi/2-tgt_inc*constant:degtorad)*body:radius.
    if tgt_inc <=latitude return 0.
    set interct_point_1 to lng(180-arcSin(latitude/tgt_inc)+tgt_lan+latitude*13.4/45). // arcSin of sin/sin
    set interct_point_2 to lng(arcSin(latitude/tgt_inc)+tgt_lan-latitude*13.4/45).  
    set angle to min(lng(interct_point_1-site_lng),lng(interct_point_2-site_lng)).
    set t to angle/kerbin:angularVel:mag*constant:degtorad.
    return t.
}
clearscreen.
print tgt_eta() at (0,7).
warpto(time:seconds+tgt_eta()-15).
wait 5.


    