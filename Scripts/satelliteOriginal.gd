extends Sprite2D
var elapsed = 0.0
var min_angle = deg_to_rad(0)
var max_angle = deg_to_rad(90)
var direction = Vector2(-1, 1)
var s = false
var fac = 3.5
var maxx = 600
var minx = 550
var maxy = 263
var miny = 213
func _process(delta):
	rotation += delta*0.01
	if s == false:
	#scale<=Vector2(0.58,0.58) && scale>=Vector2(0.38,0.38):
		position+=Vector2(fac*delta,fac*delta)
		if position>=Vector2(maxx,maxy):
			s = true
	if s == true:
	#scale<=Vector2(0.38,0.38):
		position-=Vector2(fac*delta,fac*delta)
		if position<=Vector2(minx,miny):
			s = false
