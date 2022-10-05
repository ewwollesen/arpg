extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export(int) var acceleration = 300
export(int) var max_speed = 50
export(int) var friction = 200

enum {
	IDLE,
	WANDER,
	CHASE,
}

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var state = CHASE

onready var stats: = $Stats
onready var playerDetectionZone: = $PlayerDetectionZone
onready var sprite: = $AnimatedSprite
onready var hurtBox: = $HurtBox


func _physics_process(delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, friction * delta)
	knockback = move_and_slide(knockback)

	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
			seek_player()
		
		WANDER:
			pass
		
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				var direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
			else:
				state = IDLE

			sprite.flip_h = velocity.x < 0
	
	velocity = move_and_slide(velocity)


func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE


func _on_HurtBox_area_entered(area: Area2D) -> void:
	knockback = area.knockback_vector * 120
	stats.health -= area.damage
	hurtBox.create_hit_effect()
	

func _on_Stats_noHealth() -> void:
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
