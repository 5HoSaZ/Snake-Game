extends Area2D

signal eaten

func _on_area_entered(_area):
	eaten.emit()
