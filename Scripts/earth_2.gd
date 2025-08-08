extends Sprite2D
var elapsed = 0.0
var min_angle = deg_to_rad(0)
var max_angle = deg_to_rad(90)
var direction = Vector2(-1, 1)
var s = false
var fac = 0.01
var max = 0.66
var min = 0.61
func _process(delta):
	rotation = lerp_angle(min_angle, max_angle, elapsed)
	elapsed+=delta*0.03
	if s == false:
	#scale<=Vector2(0.58,0.58) && scale>=Vector2(0.38,0.38):
		scale+=Vector2(fac*delta,fac*delta)
		if scale>=Vector2(max,max):
			s = true
	if s == true:
	#scale<=Vector2(0.38,0.38):
		scale-=Vector2(fac*delta,fac*delta)
		if scale<=Vector2(min,min):
			s = false
