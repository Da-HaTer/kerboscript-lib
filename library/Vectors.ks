//vetors
lock shipface to ship:facing:vector.
lock xaxis to v(2,0,0).
lock yaxis to v(0,2,0).
lock zaxis to v(0,0,2).
lock northvec to north:vector.
lock southvec to north:vector*-1.
lock upvec to up:vector.
lock downvec to up:vector*-1.
lock eastvec to north +r(0,-90,0):vector.
lock westvec to north +r(0,90,0):vector.
function GVEC{
	parameter vec.//vector end
	parameter color is rgb(random()*5,random()*5,random()*5).
	parameter name is "N/A".
	return vecdraw(
		v(0,0,0),
		vec,
		color,
		name,
		1,
		true,
		0.3
	).
} //draw vector,name

set spinarrow to {
	set sa to vecdraw(v(0,0,0),v(5,0,0),green "Spinn me right round",1,true,0.2).
	set vd:vecupdater to{
		return ship:up:vector*5*sin(time:seconds*180)+ship:north:vector*5*cos(time:seconds*180).}.
	wait 5.
	print "stopping spinn".
	set vd:vecupdater to donothing.
	wait 3.
	print "removing vector".
	set vd to false.
	}.
 // some spining vector
set v:vecupdater to{return false.}
//runway coordinates
function rwev{//runway east vector
	parameter alt is 70.
	return vessel("Runway East"):geoposition:altitudeposition(alt)+north:vector.
}
function rwwv{//runway west vector
	parameter alt is 70.
	vessel("Runway West"):geoposition:altitudeposition(alt)+north:vector*3.
}
lock vw to rwwv(70). //runway west coordinate vector
lock ve to rwev(70).
//position relative to runway
lock dw to vw:mag.//distance to runway
lock de to ve:mag.
lock ns to{// north /south
	parameter vec.
	if vang(north:vector,vec)>90{ return "north".}//ship is north of runway
	else {return "south".}
}

//landing:
if dw >de{
	lock rv to  //runway vector	
}