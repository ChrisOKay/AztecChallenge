
extends Node

const BUMPINESS = 0.3 # From 0 (completely smooth) to 1 (extremely bumpy);
const FERTILITY = 0.25 # From 0 (no cactuses at all) to 1 (thick forest)
const TILE_SIZE = 40 # Don't change this without resizing all images accordingly
const END_OF_LEVEL = 240 

var MAX_HEIGHT = 140 # maximum height of wall columns
var V_OFFSET = 335 # Vertical offset of wall columns on Stage
var scnPhaseTitle = preload ("res://scenes/PhaseTitle.tscn")
var scnWall = preload ("res://scenes/Wall.tscn")
var scnPlatform = preload ("res://scenes/Platform.tscn")
var scnCactus = preload ("res://scenes/Cactus.tscn")

func _ready():
	# ====== Phase 3 "Grounds & Columns" =====
	#    (Length: 20 + 60 Tiles)
	
	# ------ Tiles 160-180: Title only ------
	var ndPhaseTitle = scnPhaseTitle.instance()
	ndPhaseTitle.set_text("Grounds & Columns")
	ndPhaseTitle.set_pos(Vector2(170 * TILE_SIZE,300))
	add_child(ndPhaseTitle)
	
	# ------ Tiles 180-240: Landscape without platforms ------
	# set initial wall height
	var h = floor(rand_range(0,MAX_HEIGHT)/TILE_SIZE)
	
	for i in range(180,240):

		# create new wall column, set location and add to Stage
		var ndWall = scnWall.instance()
		ndWall.translate(Vector2(i*TILE_SIZE,V_OFFSET+(h*TILE_SIZE)))
		add_child (ndWall)

		# add cactuses every so often
		if randf() < FERTILITY:
			var ndCactus = scnCactus.instance()
			ndCactus.translate(Vector2(i*TILE_SIZE, V_OFFSET+(h*TILE_SIZE)))
			add_child(ndCactus)
			
		# change wall height every so often
		if randf() < BUMPINESS:
			h = floor(rand_range(0,MAX_HEIGHT)/TILE_SIZE)

	# ------ Add platforms ------
	MAX_HEIGHT = 160 # maximum height of wall columns
	V_OFFSET = 175 # Vertical offset of wall columns on Stage

	var i = 180
	while i < 240:
		# set platform height and length
		var h = floor(rand_range(0,MAX_HEIGHT)/TILE_SIZE)
		var l = floor(randf()*5)+1

		# create new tunnel column, set location and add to Stage
		var j
		for j in range(i, i + l):
			var ndPlatform = scnPlatform.instance()
			ndPlatform.translate(Vector2(j*TILE_SIZE,V_OFFSET+(h*TILE_SIZE)))
			add_child (ndPlatform)
			
		i += l + 4

		h = floor(rand_range(0,MAX_HEIGHT)/TILE_SIZE)
