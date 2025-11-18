class_name CatMask extends Node2D

signal mouse_entered()
signal mouse_exited()

@export var mask_status: bool
@onready var base_sprite: Sprite2D = $MaskSprite
@onready var no_mask_selection: Polygon2D = $Area2D/Polygon2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MaskSprite.visible = true
	no_mask_selection.visible = false
	
func set_mask_status(_mask_status: bool):
	mask_status = _mask_status

func highlight():
	base_sprite.set_modulate(Color(0.9,0.9,0.9))
	
func un_highlight():
	base_sprite.set_modulate(Color(1,1,1))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if mask_status:
		$MaskSprite.visible = true
	elif !mask_status:
		$MaskSprite.visible = false

func _on_area_2d_mouse_entered() -> void:
	mouse_entered.emit()
	highlight()

func _on_area_2d_mouse_exited() -> void:
	mouse_exited.emit()
	un_highlight()
