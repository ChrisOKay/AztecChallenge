
extends Node2D

var scnWall = preload("res://scenes/Wall.tscn")
var tile_size = 40

func _ready():
	randomize()
	
	# set initial wall height
	var h = floor(rand_range(0,200)/tile_size)
	
	for i in range(20):
		#add new wall column to Stage
		var ndWall = scnWall.instance()
		add_child (ndWall)
		
		# change height every so often
		if randf() > 0.5:
			h = floor(rand_range(0,200)/tile_size)
		
		# set location of column on Stage
		ndWall.translate(Vector2(100+(tile_size*i),300+(h*tile_size)))

		# TODO: Add random cactuses
