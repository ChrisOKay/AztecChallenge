
extends RigidBody2D

# member variables here, example:
var x_speed = 100
onready var animplayer = get_node("Sprite/AnimationPlayer")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	animplayer.play("Walking")
	set_linear_velocity(Vector2(x_speed,0))
	


