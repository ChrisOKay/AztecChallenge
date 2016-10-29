
extends Node2D

const JUMP_SPEED = 280 # Vertical speed used both for upward and downward movement
const WALK_SPEED = 80 # Horizonal scrolling speed
const JUMP_VALUES = \
	{"LOW": \
		{"height":60, "sound":"jump1", "points":10}, \
	"MIDDLE": \
		{"height":120, "sound":"jump2", "points":50}, \
	"HIGH": \
		{"height":180, "sound":"jump3", "points":100}}
const MAX_HEIGHT = 140 # maximum height of wall columns
const V_OFFSET = 335 # Vertical offset of wall columns on Stage
const BUMPINESS = 0.3 # From 0 (completely smooth) to 1 (extremely bumpy);
const FERTILITY = 0.25 # From 0 (no cactuses at all) to 1 (thick forest)
const TILE_SIZE = 40 # Don't change this without resizing all images accordingly

var scnPhaseTitle = preload ("res://scenes/PhaseTitle.tscn")
var scnWall = preload ("res://scenes/Wall.tscn")
var scnCactus = preload ("res://scenes/Cactus.tscn")
var curGameNode = Node.new() # temporary node to quickly delete all subnodes
var players = [] # array of active players
var intHighscore = 0

var idle_cycles = 0
# Workaround for a physics engine bug
# see https://godotengine.org/qa/6835/how-to-set_global_pos-of-kinematicbody2d

var intSteps = 0
var arrReplayLog = []
# an array of logged player positions for instant replay

func startLevel(intLevel):
	intSteps = 0
	arrReplayLog.clear()
	
	for p in players:
		p.set_pos(p.initial_pos)
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
	
			# if sliding horizontally is possible - do it
			if n.x == 0: 
				motion = n.slide(motion)
				p.move(motion)
			
			# is the player (still) hitting the wall now?
			if p.is_colliding() and (p.get_collision_normal().x != 0):
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
			
	if get_node("Player1").get_pos().x > 90 * TILE_SIZE:
		set_fixed_process(false)
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
	curGameNode.free()
	
	# create new landscape
	curGameNode = Node.new()
	add_child(curGameNode)
	
	# ====== Phase 1 "The Grounds" =====
	#    (Length: 20 + 60 Tiles)
	
	# ------ Tiles 0-20: Title only ------
	var ndPhaseTitle = scnPhaseTitle.instance()
	ndPhaseTitle.set_text("The Grounds")
	ndPhaseTitle.set_pos(Vector2(400,300))
	curGameNode.add_child(ndPhaseTitle)
	
	# ------ Tiles 21-60: Landscape without platforms ------
	# set initial wall height
	var h = floor(rand_range(0,MAX_HEIGHT)/TILE_SIZE)
	
	for i in range(20,80):

		# create new wall column, set location and add to Stage
		var ndWall = scnWall.instance()
		ndWall.translate(Vector2(i*TILE_SIZE,V_OFFSET+(h*TILE_SIZE)))
		curGameNode.add_child (ndWall)

		# add cactuses every so often
		if randf() < FERTILITY:
			var ndCactus = scnCactus.instance()
			ndCactus.translate(Vector2(i*TILE_SIZE, V_OFFSET+(h*TILE_SIZE)))
			curGameNode.add_child(ndCactus)
			
		# change wall height every so often
		if randf() < BUMPINESS:
			h = floor(rand_range(0,MAX_HEIGHT)/TILE_SIZE)
		
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
	
	for i in range(1, arrReplayLog.size(), players.size()):
		get_node("Player1").set_pos(arrReplayLog[i]) # update player position
		var newCanvasPos = Matrix32(0,Vector2(-get_node("Player1").get_pos().x+150,0))
		get_viewport().set_canvas_transform(newCanvasPos) # scroll canvas
		if players.size() == 2:
			get_node("Player2").set_pos(arrReplayLog[i+1])
		yield( get_tree(), "idle_frame" ) # wait for next idle frame
