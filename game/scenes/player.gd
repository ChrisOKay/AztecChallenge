
extends KinematicBody2D

const JUMP_SPEED = 280
const WALK_SPEED = 80
const JUMP_HEIGHTS = {"LOW":60, "MIDDLE":120, "HIGH":180}

var velocity
var can_jump
var yet_to_jump = 0 # distance to the highest point of the current jump

func _fixed_process(delta):
	
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
		# let player die if collision is not caused by downward movement
		if test_move(Vector2(motion.x, min(0,motion.y))):
			get_node("Sprite/AnimationPlayer").play("Dying")
			set_fixed_process(false)
			var t = get_node("../Timer")
			t.set_wait_time(2.5)
			t.connect("timeout", self, "startLevel", [1], CONNECT_ONESHOT)
			t.start()
			return
		
		can_jump = true
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)
	else:
		can_jump = false

	moveGroundAndCanvas()

func _ready():
	hide()

func startLevel(intLevel):
	set_pos(Vector2(90, 430))
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
	