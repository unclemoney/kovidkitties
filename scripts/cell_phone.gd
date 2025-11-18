class_name CellPhone extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale = Vector2(1.5, 1.5)
	pass # Replace with function body.

func make_visible():
	visible = true
	
func make_invisible():
	visible = false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_acknowledge_button_pressed() -> void:
	make_invisible()
	#pass # Replace with function body.
