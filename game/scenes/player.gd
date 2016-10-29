
extends KinematicBody2D

var can_jump # flag indicating the ability to jump
var yet_to_jump = 0 # distance to the highest point of the current jump
var intScore = 0 # current score
var intLifes = 3 # number of lifes