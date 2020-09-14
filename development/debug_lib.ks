//debug library

function parts{
    clearscreen.
    set terminal:width to 60.
    set terminal:height to ship:parts:length+stage:number+10.
    set i to 2.
    set j to 0.
    set lst_stg to 0.
    function hr{
    	parameter col.
    	parameter line.
    	print "─────────────────────────────────────────────────────────────────" at (col,line).
    }
 		print "stage" at (27,1).
        print "part" at (0,1).
        print "|" at (25,1).
        print "|"   at (35,1).
        print "id"  at (40,1).

    for p in ship:parts{
        
        set stg to p:stage.
        if stg <> lst_stg{
            set lst_stg to stg.
            hr(0,i).
            set i to i+1.
        }
        print stg at (27,i).
        print p:name at (0,i).
        print "|" at (25,i).
        print "|"   at (35,i).
        print j at (40,i).
        set i to i+1. 
        set j to j+1.
    }
}
parts().
