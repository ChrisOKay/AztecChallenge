
extends Node

const MAX_HEIGHT = 160 # maximum height of wall columns
const V_OFFSET = 175 # Vertical offset of wall columns on Stage
const TILE_SIZE = 40 # Don't change this without resizing all images accordingly
const END_OF_LEVEL = 160

var scnPhaseTitle = preload ("res://scenes/PhaseTitle.tscn")
var scnTunnel = preload ("res://scenes/Tunnel.tscn")
var scnCactus = preload ("res://scenes/Cactus.tscn")

func _ready():
	# ====== Phase 2 "Columns" =====
	#    (Length: 20 + 60 Tiles)
	
	# ------ Tiles 80-100: Title only ------
	var ndPhaseTitle = scnPhaseTitle.instance()
	ndPhaseTitle.set_text("Columns")
	ndPhaseTitle.set_pos(Vector2(90*TILE_SIZE,300))
	add_child(ndPhaseTitle)
	
	# ------ Tiles 100-160: Platforms ------
	var i = 100
	while i < 160:
		# set tunnel height and length
		var h = floor(rand_range(0,MAX_HEIGHT)/TILE_SIZE)
		var l = floor(randf()*5)+1

		# create new tunnel column, set location and add to Stage
		var j
		for j in range(i, i + l):
			var ndTunnel = scnTunnel.instance()
			ndTunnel.translate(Vector2(j*TILE_SIZE,V_OFFSET+(h*TILE_SIZE)))
			add_child (ndTunnel)
			
		i += l + 4

		h = floor(rand_range(0,MAX_HEIGHT)/TILE_SIZE)


