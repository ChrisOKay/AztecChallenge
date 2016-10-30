
extends KinematicBody2D

export(NodePath) var scoreNode # link to score counter on Stage
export(NodePath) var lifesNode # link to life counter on Stage
 
export(String) var jumpKeyHigh = "W"
export(String) var jumpKeyMiddle = "S"
export(String) var jumpKeyLow = "X"

var can_jump # flag indicating the ability to jump
var yet_to_jump = 0 # distance to the highest point of the current jump
var intScore = 0 # current score
var intLifes = 3 # number of lifes

var initial_pos # save initial placement for restart

func _ready():
	initial_pos = get_pos()

func reset():
	set_pos(initial_pos) # reset position
	hide()
	intLifes = 3 # reset lifes
	get_node(lifesNode).set_frame(3) # set player lifes to 3
	intScore = 0 # reset score
	get_node(scoreNode).set_text("000000")
