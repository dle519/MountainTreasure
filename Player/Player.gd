extends KinematicBody2D

enum{
	MOVE,
	ATTACK
}
var state = MOVE
var MAX_SPEED = 200
var ACCELERATION = 500
var motion = Vector2.ZERO
var stats = PlayerStats


onready var animationPlayer = $AnimationPlayer # $ is access to the node in the tree
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback") # gets the node state
onready var swordHB = $HitboxAxis/SwordHitBox
onready var hurtBox = $Hurtbox

func _ready():
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ATTACK:
			attack_state(delta)

# function to move the player
func move_state(delta):
	var axis = get_input_axis()
	# if the player is not moving
	if axis == Vector2.ZERO:
		animationState.travel("Idle")
		apply_friction(ACCELERATION * delta)
	# else the player is moving, apply movement values
	else:
		animationTree.set("parameters/Idle/blend_position", axis)
		animationTree.set("parameters/Run/blend_position", axis)
		animationTree.set("parameters/Attack/blend_position", axis)
		animationState.travel("Run")
		apply_movement(axis * ACCELERATION * delta)
	# continue motion, even against walls
	motion = move_and_slide(motion)
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func attack_state(delta):
	motion = Vector2.ZERO
	animationState.travel("Attack")
	
func attack_anim_finished():
	state = MOVE

func get_input_axis():
	var axis = Vector2.ZERO
	# get x and y axis of movement values. positve values means to right or down
	axis.x = Input.get_action_strength("ui_right")- Input.get_action_strength("ui_left")
	axis.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	return axis.normalized()

func apply_friction(amount):
	# subtract our motion with a decreasing vector value in the opposite direction to slow down
	if motion.length() > amount:
		motion -= motion.normalized() * amount
	else:
		motion = Vector2.ZERO
	
func apply_movement(accel):
	motion += accel
	# cap the motion speed
	motion = motion.clamped(MAX_SPEED)
	


func _on_Hurtbox_area_entered(area):
	stats.health -= 1
	hurtBox.start_invincibility(0.5)
	hurtBox.create_hit_effect()
