
extends KinematicBody2D

const JUMP_SPEED = 280
const WALK_SPEED = 80
const JUMP_HEIGHTS = {"LOW":60, "MIDDLE":120, "HIGH":180}

var can_jump
var yet_to_jump = 0 # distance to the highest point of the current jump

var idle_cycles = 0
# Workaround for a physics engine bug
# see https://godotengine.org/qa/6835/how-to-set_global_pos-of-kinematicbody2d

func _fixed_process(delta):
	if idle_cycles > 0:
		idle_cycles -= 1
		return
		
	var velocity = 0
	
	if can_jump:
		if Input.is_key_pressed(KEY_W):
			yet_to_jump = JUMP_HEIGHTS["HIGH"]
			can_jump = false
		elif Input.is_key_pressed(KEY_S):
			yet_to_jump = JUMP_HEIGHTS["MIDDLE"]
			can_jump = false
		elif Input.is_key_pressed(KEY_X):
			yet_to_jump = JUMP_HEIGHTS["LOW"]
			can_jump = false

	# move up as long until the highest point is reached
	if yet_to_jump > 0:
		velocity = Vector2(WALK_SPEED, -JUMP_SPEED)
		yet_to_jump -= JUMP_SPEED * delta
	else:
		velocity = Vector2(WALK_SPEED, JUMP_SPEED)
	
	var motion = velocity * delta
	
	motion = move(motion)
	
	if (is_colliding()):
		var n = get_collision_normal()

		# if sliding horizontally is possible - do it
		if n.x == 0: 
			motion = n.slide(motion)
			move(motion)
		
		# is the player (still) hitting the wall now?
		if is_colliding() and (get_collision_normal().x != 0):
			set_fixed_process(false)
			print (get_collider().get_name(), ", ", get_collision_normal().x, "/", get_collision_normal().y)
			get_node("Sprite/AnimationPlayer").play("Dying")
			var t = get_node("../Timer")
			
			var intLifecount = get_node("../HUD/P1_Lifes").get_frame()
			if intLifecount > 0:
				# restart level
				get_node("../HUD/P1_Lifes").set_frame(intLifecount-1)
				t.connect("timeout", self, "startLevel", [1], CONNECT_ONESHOT)
			else:
				# restart game
				t.connect("timeout", get_parent(), "initGame", [],  CONNECT_ONESHOT)
			t.start()

		can_jump = true
	else:
		can_jump = false
		
	moveGroundAndCanvas()

func startLevel(intLevel):
	set_pos(Vector2(90, 420))
	idle_cycles = 10 # https://godotengine.org/qa/6835/how-to-set_global_pos-of-kinematicbody2d
	get_node("Sprite/AnimationPlayer").play("Walking")
	moveGroundAndCanvas()
	if is_hidden(): show()
	set_fixed_process(true)

func moveGroundAndCanvas():
	# continuosly move invisible ground to prevent player from falling through
	get_node("../Ground").set_pos(Vector2(get_pos().x,0))
	
	# transform canvas to follow Player1
	var newCanvasPos = Matrix32(0,Vector2(-get_pos().x+150,0))
	get_viewport().set_canvas_transform(newCanvasPos)
	