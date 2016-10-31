
extends Node2D

const TILE_SIZE = 40 # Don't change this without resizing all images accordingly
const JUMP_SPEED = 280 # Vertical speed used both for upward and downward movement
const WALK_SPEED = 80 # Horizonal scrolling speed
const JUMP_VALUES = \
	{"LOW": \
		{"height":80, "sound":"jump1", "points":10}, \
	"MIDDLE": \
		{"height":140, "sound":"jump2", "points":50}, \
	"HIGH": \
		{"height":200, "sound":"jump3", "points":100}}

const LEVEL = [ \
	preload ("res://scenes/Level_1.gd"), \
	preload ("res://scenes/Level_2.gd")]

var levels = [] # array of created levels
var players = [] # array of active players
var intHighscore = 0

var idle_cycles = 0
# Workaround for a physics engine bug
# see https://godotengine.org/qa/6835/how-to-set_global_pos-of-kinematicbody2d

var intSteps = 0
var arrReplayLog = [] # an array of logged player positions for instant replay
var nextReplayPoint = 85

func startLevel(intLevel):
	intSteps = 0
	arrReplayLog.clear()
	
	for p in players:
		p.set_pos(Vector2(p.initial_pos.x + (nextReplayPoint - 85) * TILE_SIZE, p.initial_pos.y))
		p.get_node("Sprite/AnimationPlayer").play("Walking")
		if p.is_hidden(): p.show()

	idle_cycles = 10 # https://godotengine.org/qa/6835/how-to-set_global_pos-of-kinematicbody2d
	moveGroundAndCanvas()
	set_fixed_process(true)

func moveGroundAndCanvas():
	# continuosly move invisible ground to prevent player from falling through
	get_node("Ground").set_pos(Vector2(get_node("Player1").get_pos().x-200,0))
	
	# transform canvas to follow Player1
	var newCanvasPos = Matrix32(0,Vector2(-get_node("Player1").get_pos().x+150,0))
	get_viewport().set_canvas_transform(newCanvasPos)

func _fixed_process(delta):
	if idle_cycles > 0:
		idle_cycles -= 1
		return
		
	for p in players:
		var velocity = 0
		
		if p.can_jump:
			var curJump = {}
			if Input.is_key_pressed(p.jumpKeyHigh.ord_at(0)): curJump = JUMP_VALUES["HIGH"]
			if Input.is_key_pressed(p.jumpKeyMiddle.ord_at(0)): curJump = JUMP_VALUES["MIDDLE"]
			if Input.is_key_pressed(p.jumpKeyLow.ord_at(0)): curJump = JUMP_VALUES["LOW"]
			if curJump.size() > 0:
				p.yet_to_jump = curJump["height"]
				get_node("SamplePlayer").play(curJump["sound"])
				p.intScore += curJump["points"]
				p.get_node(p.scoreNode).set_text \
					("%06d" % p.intScore)
				p.can_jump = false
	
				# Update highscore, if necessary
				if intHighscore < p.intScore:
					intHighscore = p.intScore
					get_node("HUD/Highscore").set_text("%06d" % intHighscore)
	
		# move up as long until the highest point is reached
		if p.yet_to_jump > 0:
			velocity = Vector2(WALK_SPEED, -JUMP_SPEED)
			p.yet_to_jump -= JUMP_SPEED * delta
		else:
			velocity = Vector2(WALK_SPEED, JUMP_SPEED)
		
		var motion = velocity * delta
		
		motion = p.move(motion)
		
		if p.is_colliding():
			var n = p.get_collision_normal()
	
			# if colliding with ground only - slide
			if n.y == -1: 
				motion = n.slide(motion)
				p.move(motion)
			
			# is the player (still) hitting the ground only?
			if p.is_colliding() and (p.get_collision_normal().y != -1):
				set_fixed_process(false)
				p.get_node("Sprite/AnimationPlayer").play("Dying")
				get_node("SamplePlayer").play("fail")
				var t = get_node("Timer")
				
				if p.intLifes > 0:
					# restart level
					p.intLifes -= 1
					p.get_node(p.lifesNode).set_frame(p.intLifes)
					t.connect("timeout", self, "startLevel", [1], CONNECT_ONESHOT)
				else:
					# restart game
					t.connect("timeout", self, "initGame", [],  CONNECT_ONESHOT)
				t.start()
	
			p.can_jump = true
		else:
			p.can_jump = false # no jumps w/o touching ground
		
		 # log every third position for future replay
		intSteps += 1
		if intSteps % 3 == 0:
			arrReplayLog.append(p.get_pos())
			
	if get_node("Player1").get_pos().x > nextReplayPoint * TILE_SIZE:
		set_fixed_process(false)
		nextReplayPoint += 80
		# instant replay! Make some noise!
		get_node("SamplePlayer").play("replay")
		runInstantReplay()
		return
	
	moveGroundAndCanvas() # scrolling

func _ready():
	randomize()
	initGame()

func initGame():
	get_node("SamplePlayer").play("theme_mod2") # play intro
	get_node("HUD/Menu").show() # show menu options
	get_node("Player1").reset() # reset Player 1
	get_node("Player2").reset() # reset Player 2
	
	# move camera to begin of Phase 1 (pos 0,0,0)
	get_viewport().set_canvas_transform(Matrix32(0,Vector2(0,0)))
	
	# delete previously created landscape
	for l in levels: l.free()
	levels.clear()

	# create new landscape
	for l in LEVEL: levels.append(l.new())
	for n in levels: add_child(n)
	
	# listen to key events
	set_process_input(true)

func _input(event):
	if (event.type == 1) and (event.scancode == KEY_1):
		set_process_input(false)
		get_node("HUD/Menu").hide()
		players = [get_node("Player1")]
		startLevel(1)
		
	if (event.type == 1) and (event.scancode == KEY_2):
		set_process_input(false)
		get_node("HUD/Menu").hide()
		players = [get_node("Player1"), get_node("Player2")]
		startLevel(1)

func runInstantReplay():
	var i
	for p in players:
		# temporary disable collision detection for instant replay
		p.get_node("CollisionShape2D").set_trigger(true)
		p.get_node("Sprite/AnimationPlayer").play("Running")
	
	for i in range(0, arrReplayLog.size(), players.size()):
		get_node("Player1").set_pos(arrReplayLog[i]) # update player position
		var newCanvasPos = Matrix32(0,Vector2(-get_node("Player1").get_pos().x+150,0))
		get_viewport().set_canvas_transform(newCanvasPos) # scroll canvas
		if players.size() == 2:
			get_node("Player2").set_pos(arrReplayLog[i+1])
		yield( get_tree(), "idle_frame" ) # wait for next idle frame
	
	for p in players:
		# reactivate collision detection
		p.get_node("CollisionShape2D").set_trigger(false)
		p.get_node("Sprite/AnimationPlayer").play("Walking")
	
	arrReplayLog.clear()
	set_fixed_process(true) # continue game
