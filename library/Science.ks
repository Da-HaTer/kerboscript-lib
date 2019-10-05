parameter recovery_mode is 1. //1 store //2 transmit //-1 retract
parameter Transmision_antenna_id is 0. //0 all antennas //>0 science antenna
//runoncepath("0:/library/sattcom.ks").
//runoncepath("0:/library/kos.lib.ks").
libreq("sattcom").
libreq("kos.lib.ks").

function main{
  for p in ship:parts{
    local m is p:allmodules.
    if m:contains("modulescienceexperiment") or m:contains("dmmodulescienceanimate") {
      if m:contains("modulescienceexperiment"){
        set m to p:getmodule("modulescienceexperiment").
      }
      else set m to p:getmodule("dmmodulescienceanimate").
      if recovery_mode=-1{
        Retract_experiments(m).
      }
      else Do_Science(m).
    }
  }
}
  function Do_Science{
    parameter m.
    if not (m:hasdata) m:deploy.
    for data in m:data{
      if m:hasdata and m:data[0]:sciencevalue >0{
        if recovery_mode=1{
          store_Data().
          wait(0.5).
        }
        else if recovery_mode=2{
          //transmit
          if Transmision_antenna_id =0 activate_all().
          else activate(Transmision_antenna_id).
          wait (0.5). 
          m:transmit.
          wait (5).
          if Transmision_antenna_id=0 deactivate_all().
          else deactivate(Transmision_antenna_id).
        }  
      }
    m:dump.
    m:reset.
    }
  } 

function Retract_experiments{
  parameter m.
  set event to slice(m:allevents[0],11,-13).
  if m:deployed and event<>"crew report" m:doevent(event).// to avoid deploying undeployed.
//deactivate(Transmision_antenna_id).
}

function Store_Data{
  local p is ship:partsdubbed("ScienceBox").
  if p:length =0 return false.
  else set p to p[0].
  local m is p:getmodule("modulescienceContainer").
  for i in m:allevents{
    if slice(m:allevents[0],11,-13)="Container: collect all"{
  m:doevent("Container: collect all").
    }
  }
}
main().