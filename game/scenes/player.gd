
extends KinematicBody2D

const JUMP_SPEED = 280
const WALK_SPEED = 80
const JUMP_VALUES = \
	{"LOW": \
		{"height":60, "sound":"jump1", "points":10}, \
	"MIDDLE": \
		{"height":120, "sound":"jump2", "points":50}, \
	"HIGH": \
		{"height":180, "sound":"jump3", "points":100}}

var can_jump
var yet_to_jump = 0 # distance to the highest point of the current jump
var intScore = 0 # 

var idle_cycles = 0
# Workaround for a physics engine bug
# see https://godotengine.org/qa/6835/how-to-set_global_pos-of-kinematicbody2d

var intSteps = 0
var arrReplayLog = [] # an array of logged y-Values for instant replay

func _fixed_process(delta):
	
	if idle_cycles > 0:
		idle_cycles -= 1
		return
		
	var velocity = 0
	
	if can_jump:
		var curJump = {}
		if Input.is_key_pressed(KEY_W): curJump = JUMP_VALUES["HIGH"]
		if Input.is_key_pressed(KEY_S): curJump = JUMP_VALUES["MIDDLE"]
		if Input.is_key_pressed(KEY_X): curJump = JUMP_VALUES["LOW"]
		if curJump.size() > 0:
			yet_to_jump = curJump["height"]
			get_node("../SamplePlayer").play(curJump["sound"])
			intScore += curJump["points"]
			get_node("../HUD/P1_Score").set_text("%06d" % intScore)
			can_jump = false

			# Update highscore, if necessary
			if get_parent().intHighscore < intScore:
				get_parent().intHighscore = intScore
				get_node("../HUD/Highscore").set_text("%06d" % intScore)			

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
			get_node("Sprite/AnimationPlayer").play("Dying")
			get_node("../SamplePlayer").play("fail")
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
		can_jump = false # no jumps w/o touching ground
		
	if get_pos().x > 90 * get_parent().TILE_SIZE:
		# instant replay!
		set_fixed_process(false)
		runInstantReplay()
		return

	 # log every third position for future replay
	intSteps += 1
	if intSteps % 3 == 0:
		arrReplayLog.append(get_pos())
	
	moveGroundAndCanvas() # scrolling

func runInstantReplay():
	var i
	# temporary disable collision detection for instant replay
	get_node("CollisionShape2D").set_trigger(true)
	
	get_node("Sprite/AnimationPlayer").play("Running")
	for i in range(arrReplayLog.size()):
		set_pos(arrReplayLog[i])
		moveGroundAndCanvas() # scrolling
		yield( get_tree(), "idle_frame" ) # wait for next idle frame

func startLevel(intLevel):
	intSteps = 0
	arrReplayLog.clear()
	set_pos(Vector2(90, 430))
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