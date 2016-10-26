
extends Node2D

const MAX_HEIGHT = 140 # maximum height of wall columns
const V_OFFSET = 335 # Vertical offset of wall columns on Stage
const BUMPINESS = 0.3 # From 0 (completely smooth) to 1 (extremely bumpy);
const FERTILITY = 0.25 # From 0 (no cactuses at all) to 1 (thick forest)

var scnPhaseTitle = preload ("res://scenes/PhaseTitle.tscn")
var scnWall = preload ("res://scenes/Wall.tscn")
var scnCactus = preload ("res://scenes/Cactus.tscn")
var tile_size = 40

func _ready():
	randomize()
	
	# ====== Phase 1 "The Grounds" =====
	#    (Length: 20 + 60 Tiles)
	
	# ------ Tiles 0-20: Title only ------
	var ndPhaseTitle = scnPhaseTitle.instance()
	ndPhaseTitle.set_text("The Grounds")
	ndPhaseTitle.set_pos(Vector2(400,300))
	add_child(ndPhaseTitle)
	
	# ------ Tiles 21-60: Landscape without platforms ------
	# set initial wall height
	var h = floor(rand_range(0,MAX_HEIGHT)/tile_size)
	
	for i in range(20,80):

		# create new wall column, set location and add to Stage
		var ndWall = scnWall.instance()
		ndWall.translate(Vector2(i*tile_size,V_OFFSET+(h*tile_size)))
		add_child (ndWall)

		# add cactuses every so often
		if randf() < FERTILITY:
			var ndCactus = scnCactus.instance()
			ndCactus.translate(Vector2(i*tile_size, V_OFFSET+(h*tile_size)))
			add_child(ndCactus)
			
		# change wall height every so often
		if randf() < BUMPINESS:
			h = floor(rand_range(0,MAX_HEIGHT)/tile_size)
		
	# listen to key events
	set_process_input(true)
		
func _input(event):
	if event.is_pressed() and (event.scancode == KEY_1):
		get_node("HUD/Menu").hide()
		get_node("Player1").startLevel(1)
		
	#TODO: Add two player mode