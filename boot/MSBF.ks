//MonoTask Sattlites Boot fIl
//to add : upgrade boot file.
//         remove the abort system.
clearscreen.
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
SET TERMINAL:WIDTH      to 40. 
SET TERMINAL:HEIGHT     to 32.
set Terminal:CHARHEIGHT to 10.

edit temp.