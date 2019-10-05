list engines in myengines.
local full_mass is 0.
local fuel_mass is 0.
function stages_isp{
    local maxstage is stage:number.
    local stages is lexicon().
    from {local x is maxstage.}until x=-1 step{set x to x-1.} do{
        local totalfactor is 0.
        local totisp is 0.
        for engine in myengines{
            if engine:stage=x{
                set totalfactor to totalfactor+1.
                set totisp to totisp+engine:vacuumisp.
                if totalfactor <>0 stages:add(x,totisp/totalfactor).
            }
        }
    }
}


  
function stages_deltav{
    parameter stages.
    local dv_lex is lexicon().
    for n in stag
for p in ship:parts{
    if p:stage<=n set full_mass to full_mass+p:mass.
    if p:stage=n-1{
        for res in p:resources{
            if res:name ="liquidfuel" or res:name="oxidizer"set fuel_mass to fuel_mass+res:amount*res:density.
        }
    }
}
set dv to ship:partsdubbed("liquidengine3")[0]:vacuumisp*9.81*ln(full_mass/(full_mass- fuel_mass)).
print dv.