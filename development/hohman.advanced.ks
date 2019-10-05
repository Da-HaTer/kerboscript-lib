
function ish{
    parameter a.
    parameter b.
    parameter ishyness.
    
    return a+ishyness>b and a- ishyness <b.
}

function lng{ //calculates angles in better range
    parameter x. // longitude / latitude
    return mod(x+360000,360).
}
function point_eta{
    parameter long. //an /dn
    local last_pos is longitude .
    local step_ is 5.
    set acc_time to 0.
    set start_time to time:seconds.
    until ish(lng(long-last_pos),1,0.5){
        set acc_time to acc_time + step_.
        set last_pos to orbitat(ship,start_time+acc_time):longitude.
    }
    add node(time:seconds+acc_time,0,0,0).
}
point_eta(orbit:lan-body:rotationangle).
//time to ascending/descending node (hillclimbing) bad
set 



libreq("BRIC.ks").
libreq("Orbit.ks").
local W_mun is mun:velocity:orbit:mag/mun:altitude. //mun angular velocity 2
local W_relative is W_mun-kerbin:angularvel:mag. // 10 -2 
local sma is ship:orbit:semimajoraxis.
lock phase_lng to lng(mun:longitude+(W_mun*constant:pi*sqrt(sma^3/mu(kerbin)))+180).//mun //115 +( 0.1 deg/minute * orbit period) +180
local transition_dv is sqrt(2*mu(kerbin)/(mun:orbit:semimajoraxis+ship:semimajoraxis))-ship:velocity:orbit:mag. 

if lng(phase_lng-ship:orbit:lan)<(phase_lng-ship:orbit:lan+180) declare local pt is "AN".
else declare local pt is "DN".

//above is launch window for the moon
//improve concept parking orbit then burn to
//assuming an inclined launch it is better to launch from decending node or ascending node
//assume actual mun longitude is its current lng+transferphase
//plan when mun lng+180 is closer to either an or dn
//guess time to ascending /descending node ??????????????????????????????????????
//hill climb from there and maybe mid course correction

//1D hill climing (time)
//hillclimbing
local future_lng is site_lng.
local last_error is 180.
local step_ is 1000.
until abs(step_) <5{
    set future_lng to lng(future_lng+site_angv*step_).
    set error1 to lng(interct_point_1-future_lng).
    set error2 to lng(interct_point_2-future_lng).
    if min(error1,error2)>last_error{
        set step_ to -(step_/2). 