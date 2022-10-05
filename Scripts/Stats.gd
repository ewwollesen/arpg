extends Node

export(int) var maxHealth = 1

onready var health = maxHealth setget setHealth

signal noHealth

func setHealth(value):
	health = value
	if health <= 0:
		emit_signal("noHealth")
