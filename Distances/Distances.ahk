;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
; Right now you can  get a coupon code here: https://the-Automator.com/Learn
;*******************************************************
#SingleInstance,Force
;**************************************
LosAngelesLat:="34.052235", LosAngelesLng:="-118.243683"
OrlandoLat:="28.53834", OrlandoLng:="-81.37924"
D:=Distances(LosAngelesLat,LosAngelesLng,OrlandoLat,OrlandoLng)
;~ MsgBox % D.Miles



Distances(lat1,lon1,lat2,lon2){
	Dist:={} ;Create object for storage
	static p:=0.017453292519943295 ;1 degree in radian
	Dist.Kilometers:=12742*ASin(Sqrt(0.5-Cos((lat2-lat1)*p)/2+Cos(lat1*p)*Cos(lat2*p)*(1-Cos((lon2-lon1)*p))/2)) ;Formula borrowed from Internet search
	Dist.Meters:=Dist.Kilometers*1000 ;meters
	Dist.Miles:=Dist.Kilometers/1.609344 ;miles
	Dist.Feet:=Dist.Kilometers/0.0003048 ;feet
	Dist.Yards:=Dist.Feet/3
	return Dist
}