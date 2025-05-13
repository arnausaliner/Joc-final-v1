extends CharacterBody2D

@export var steering_angle = 0.3 # Ángulo máximo de dirección
@export var V_max = 1000 # Velocitat Màxima
@export var acceleration = 900 # Acceleració
@export var F_friction = -55.0 # Fricció
@export var F_freno = -700
@export var frenada = -1000 # Potència de frenada
@export var V_max_atras = 500 # Velocitat Màxima Enrere
@export var traction_fast = 1.0 # Tracción durante drifting
@export var traction_slow = 70.0 # Tracción normal
@export var steer_limit = 0.08 # Màxim que pot girar la roda

var wheel_base = 70
var steer_direction := 0.0
var derrapant := false
var velocitat := 0.0
var vector_V := Vector2.ZERO
var friction = 0.0
var traction = traction_slow

# Funcionament del coche GENERAL
func _physics_process(delta: float) -> void:
	vector_V = Vector2.ZERO # Asignem la direcció a "(0,0)" al inici
	particles() # Activem les particules del coche
	sonidos() # Activem els sorolls del coche
	get_input() # Mirem els Inputs del usuari
	calculate_steering(delta) # Calculem el moviment del coche
	
	velocity += vector_V * delta # Apliquem el moviment al coche
	apply_friction(delta) # Apliquem la fricció al coche
	move_and_slide() # Per a les colisions i moviment en general
	
func get_input() -> void: # Mirem els Inputs del usuari
	var turn := Input.get_axis("mou_esquerra", "mou_dreta") # Cap a on estem girant ("mou_esquerra" -1, "mou_dreta" 1)
	
	# Canviar el angle de direcció
	steer_direction += turn * deg_to_rad(steering_angle) # Passem de graus a radians (usem radians per evitar errors) i després multipliquem per "turn" (la direcció positiva o negativa, -1/1)
	steer_limit = 0.08 # Asignem al gir màxim un valor
	
	steer_limit = steer_limit / (velocity.length() * 0.001) # Contra major velocitat menys pots girar
	
	if derrapant: # Si esta derrapant pot girar més
		steer_limit = 0.25
	steer_direction = clamp(steer_direction, -steer_limit, steer_limit) # Fa que "ster_direction" sigui un valor entre +/- "steer_limit"
	
	# Centrar el volant 
	if turn == 0: # Si no esta girant el volant tornar el volant a "0"
		var V_return := 0.1 # Velocitat de tornar el volant a "0"
		if derrapant: # Si esta derrapant la velocitat de tornar a "0" és més baixa
			V_return = 0.003
		steer_direction = move_toward(steer_direction, 0.0, V_return) # Mou "steer_direction" a "0" amb velocitat "V_return"

	# Per trobar el Vector Velocitat del moviment (direcció i mòdul), depenent del que es pressioni varia en positiu o negatiu el vector "vector_V" segons una acceleració
	if Input.is_action_pressed("mou_dalt"):
		vector_V = transform.x * acceleration	
	elif Input.is_action_pressed("mou_baix"):
		vector_V = transform.x * frenada

func apply_friction(delta: float) -> void: # Apliquem la fricció al coche
	var friction_force = velocity.normalized() * friction * delta # La Força de Fricció és el vector velocitat normalitzat (sempre sigui 1 com a màxim) * la Fricció
	if friction_force.length() > velocity.length(): # Quan la Força de Fricció sigui més gran que la velocitat s'atura (en móduls de vector)
		velocity = Vector2.ZERO
	else:
		velocity += friction_force # Aplicar la Força de Fricció a la velocitat (en vectors), quan sigui més petita o igual

func calculate_steering(delta: float) -> void:
	# BICYCLE MODEL - Simulem un vehicle a 2 rodes (bicicleta), trasera (velocitat), delantera (velocitat * direcció), creem un vector que va de la roda trasera a la delantera i el multipliquem per la velocitat normalitzada per tal de trobar si els vecotrs son perpendiculars ("0") o si són iguals ("1") i la direcció (- darrere, + davant)
	
	# Calculem la posició de la roda delantera i trasera ("postition" - centre del coche, "wheel_base" - distància entre rodes delanteres i traseres)
	var rear_wheel = position - transform.x * wheel_base / 2.0 
	var front_wheel = position + transform.x * wheel_base / 2.0

	rear_wheel += velocity * delta # Asigna el vector velocitat a la roda trasera
	front_wheel += velocity.rotated(steer_direction) * delta # Asigna el vector velocitat i la direcció a la roda delantera

	var new_heading = rear_wheel.direction_to(front_wheel) # Calcula el vector resultant del vector roda trasera i roda delantera (cap a on s'ha de moure el coche)
	
	
	
	friction = F_friction #Reestablim la fricció a la fricció normal
	
	# Si es presiona "freno": la fricció s'augmenta per a frenar més ràpid (simulant el freno de mano), la tracció baixa (drifting) i posem que estem derrapant
	if Input.is_action_pressed("freno"):
		friction = F_freno
		traction = traction_fast
		derrapant = true

	# Si es solta "freno" posem que ja no estem derrapant
	elif Input.is_action_just_released("freno"):
		derrapant = false

	# Si no estem derrapant la tracció va tornant suaument a la normal
	if not derrapant:
		traction = lerp(traction, traction_slow, 0.1 * delta)

	var d = new_heading.dot(velocity.normalized()) # Multipliquem cap a on s'ha de moure el coche ("new_heading") per el vector velocitat normalitzat (màxim 1), això donarà "1" quan la direcció sigui igual i "0" quan siguin perpendiculars i + si el sentit és el mateix i - si és diferent
	
	
	if d > 0: # Si el sentit és el mateix (va endavant)
		
		velocity = lerp(velocity, new_heading * min(velocity.length(), V_max), traction * delta)  # Variem la velocitat suaument cap a la nova direcció * velocitat (les dues rodes juntes i el mòdul de la velocitat), s'agafa el mínim entre la velocitat i la velocitat màxima (si la velocitat és més que la màxima s'agafa la màxima), tot això mitjançant una velocitat (la tracció)
		
	else: # Si el sentit és diferent (va endarrere)
		velocity = -new_heading * min(velocity.length(), V_max_atras) # Variem la velocitat en el altre sentit (cap a darrere), s'agafa el mínim entre la velocitat i la velocitat màxima (si la velocitat és més que la màxima s'agafa la màxima)

	rotation = new_heading.angle() # El coche es gira per apuntar en la nova direcció

func sonidos() -> void: # Activem els sorolls del coche
	# Si velocitat és diferent de "0", "freno" esta presionat i soroll "Drift" no esta sonant, "Drift" comença a sonar, sinó, "Drift" para de sonar
	if velocity.length() != 0.0 and Input.is_action_pressed("freno"):
		if not $Drift.playing:
			$Drift.play(1.4)
	else:
		$Drift.stop()
	
	# Si velocitat és diferen a "0" i si "Throtle" no esta sonant, comença a sonar "Throtle", sinó atura "Throtle"
	if velocity.length() != 0.0:
		if not $Throtle.playing:
			$Throtle.play()
	else:
		$Throtle.stop()
	# Cambiar el valor del "pitch" (agut/greu) de "Throtle" depenent del percentatge de velocitat, per donar sensació de velocitat/acceleració
	$Throtle.pitch_scale = max(0.01, velocity.length() / V_max) # Asignar a "pitch" "velocitat/velocitat màxima" o "0.1" si el percentatge de velocitat és inferiora "0.1"
	
	
	# Si és pressiona "Claxon" i "Horn" no està sonant, comença a sonar, sinó atura'l
	if Input.is_action_pressed("Claxon"):
		if not $Horn.playing:
			$Horn.play()
	else:
		$Horn.stop()

func particles() -> void: # Activem les particules del coche
	# No hi ha particules a no ser que es pressioni el "freno" i la velocitat no sigui "0"
	$Humo.emitting = false
	if Input.is_action_pressed("freno"):
		if velocity.length() != 0.0:
			$Humo.emitting = true
