extends Area2D

func _ready() -> void:
	modulate = Color(Color.MEDIUM_ORCHID, 0.1)

func _process(delta: float) -> void:
	if Global.id_dragging:
		visible = true
	else:
		visible = false
