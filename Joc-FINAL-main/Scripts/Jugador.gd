extends CharacterBody2D



@export var velocitat: float = 0























	
	


var direccio: Vector2 = Vector2.LEFT
var velo: float = 0

var friccion := 3
var w := 0.0


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	
	if velocitat > 0:
		velocitat -= friccion
	if velocitat < 0:
		velocitat += friccion
	
	
	
	
	
	#if velocitat == 0 and (not(Input.is_action_pressed("mou_esquerra")) or not(Input.is_action_pressed("mou_dreta"))):
			#w=0.0
			#
	
	
	
	
	
	if Input.is_action_pressed("mou_dreta"):
		if velocitat > 500:
			w+=0.001
		if velocitat < -100:
			w+=0.001
			
			
		if w <0.05:
			w+= (0.00009*velocitat) 
		direccio = direccio.rotated(w)
				
	if Input.is_action_pressed("mou_esquerra"):
		if w <0.05:
			w+=(0.00009*velocitat) 
		direccio = direccio.rotated(-w)
	
	w = 0
	
	
	
		
	if Input.is_action_pressed("mou_dalt"):
		if velocitat < 700:
			velocitat += 15
	if  Input.is_action_pressed("mou_baix"):
		if velocitat > 0:
			velocitat -= 15
			
			
		if velocitat <= 10:
			if not (velocitat < -300):
				velocitat -= 7
		
		
	velocity = direccio * velocitat
	
	

	
	if move_and_slide():
		if velocitat < 0:
			velocitat += 100
		if velocitat > 0:
			velocitat -= 100
		
	
	

	print(velocitat)
	print(direccio)
	
	rotation = direccio.angle()




	
