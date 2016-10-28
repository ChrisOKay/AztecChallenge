
extends Node2D

const MAX_HEIGHT = 140 # maximum height of wall columns
const V_OFFSET = 335 # Vertical offset of wall columns on Stage
const BUMPINESS = 0.3 # From 0 (completely smooth) to 1 (extremely bumpy);
const FERTILITY = 0.25 # From 0 (no cactuses at all) to 1 (thick forest)
const TILE_SIZE = 40 # Don't change this without resizing all images accordingly

var scnPhaseTitle = preload ("res://scenes/PhaseTitle.tscn")
var scnWall = preload ("res://scenes/Wall.tscn")
var scnCactus = preload ("res://scenes/Cactus.tscn")
var curGameNode = Node.new() # temporary node to quickly delete all subnodes
var intHighscore = 0

func _ready():
	randomize()
	get_node("SamplePlayer").set_polyphony(3)	#allow up to three simultaneous sounds
	initGame()

func initGame():
	get_node("SamplePlayer").play("theme_mod2") # play intro
	get_node("HUD/Menu").show() # show menu options
	get_node("HUD/P1_Lifes").set_frame(3) # set player lifes to 3
	get_node("HUD/P1_Score").set_text("000000")
	get_node("Player1").hide() # hide player 1
	get_node("Player1").intScore = 0 # reset score
	
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
		get_node("HUD/Menu").hide()
		get_node("Player1").startLevel(1)
		set_process_input(false)
		
		#TODO: Add two player mode