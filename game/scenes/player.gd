
extends KinematicBody2D

# member variables here, example:
const yForce = 200
const WALK_SPEED = 80
onready var animplayer = get_node("Sprite/AnimationPlayer")
var velocity = Vector2()

func _fixed_process(delta):

    if Input.is_key_pressed(KEY_SPACE):
        yForce = -200
    else:
        yForce = 200


    velocity = Vector2(WALK_SPEED, yForce)

    var motion = velocity * delta
    motion = move(motion)

    if (is_colliding()):
        var n = get_collision_normal()
        motion = n.slide(motion)
        velocity = n.slide(velocity)
        move(motion)

func _ready():
	animplayer.play("Walking")
	set_fixed_process(true)

