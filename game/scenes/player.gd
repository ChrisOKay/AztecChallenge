
extends KinematicBody2D

export(NodePath) var scoreNode # link to score counter on Stage
export(NodePath) var lifesNode # link to life counter on Stage
 
var can_jump # flag indicating the ability to jump
var yet_to_jump = 0 # distance to the highest point of the current jump
var intScore = 0 # current score
var intLifes = 3 # number of lifes

var initial_x # save initial placement for restart

func _ready():
	initial_x = get_pos().x