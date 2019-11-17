"""
the planet is rotating in the game at a speed of about 174.8 m/s at it's equator
assuming a vessel is launching from the equator it will be already going at the above speed laterally
if it aims straight to the north it won't achieve a perfect 90 degrees inclinating due to the above reasons:
    the initial velocity and the added velocity vectors will be added and there will be deviation

In order to compensate some correcting angle will have to be added to the inital desired inclination, it's usually called
the launch azimuth


"""
def azimuth():
    import math

    lclat=0 #latitude of LC
    rotvel=174.8 * math.cos(math.radians(lclat)) # rotation velocity of LC
    orbvel=2250 #desired orbital velocity 
     
    negative=False
    theta = float(input("angle\n")) #desired inclination
    negative= True if theta <0 else False
    theta= abs(theta)
    theta=math.radians(theta)
    alpha= math.atan((math.sin(theta)*orbvel)/(math.cos(theta)*orbvel-rotvel)) # main formula
    alpha=math.degrees(alpha) 
    if alpha<0:
        alpha=alpha+180
    alpha= -alpha if negative else alpha
    print (alpha)

while True:
    azimuth()