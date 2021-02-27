extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/BatDeathAnimation.tscn")
onready var stats = $Stats
var vel = Vector2.ZERO
export var ACCELERATION = 400
export var MAX_SPEED = 50
export var FRICTION = 250


enum{
	IDLE,
	WANDER,
	CHASE
}

onready var playerDetZone = $PlayerDetectionZone
onready var hurtBox = $Hurtbox
var state = CHASE

func _physics_process(delta):
	match state:
		IDLE:
			vel = vel.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
		WANDER:
			pass
		CHASE:
			var player = playerDetZone.player
			if player != null:
				var playerDirection = (player.global_position - global_position).normalized()
				vel = vel.move_toward(playerDirection * MAX_SPEED, ACCELERATION * delta)
	vel = move_and_slide(vel)



func seek_player():
	if playerDetZone.can_see_player():
		state = CHASE

func _on_Hurtbox_area_entered(area):
	# reduce bat health by damage of sword
	stats.health -= area.damage
	hurtBox.create_hit_effect()

func _on_Stats_no_health():
	# make bat disappear
	queue_free()
	var enemyDeath = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeath)
	enemyDeath.global_position = global_position
