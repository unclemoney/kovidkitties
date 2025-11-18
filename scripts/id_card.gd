class_name IDCard extends Node2D

signal mouse_entered_name()
signal mouse_exited_name()
signal mouse_entered_picture()
signal mouse_exited_picture()
signal mouse_entered_breed()
signal mouse_exited_breed()

signal mouse_enter_dragging()
signal mouse_exit_dragging()
signal id_enter_body()
signal id_exit_body()

@export var id_name: String = "HELLO"
@export var id_breed: String = "Breed"
@export var id_picture_name: String = "Hello"
@export var fake_id_picture_name: String = "Hello"
@export var id_picture: Node2D

@onready var id_breed_label: Label = $IDName/IDBreedLabel
@onready var id_name_label: Label = $IDName/IDNameLabel
@onready var id_picture_set: Sprite2D = $IDPicture/IDPictureSprite

@onready var picture_selection: Polygon2D = $PictureArea/PicturePoly
@onready var name_selection: Polygon2D = $NameArea/NamePoly
@onready var breed_selection: Polygon2D = $BreedArea/BreedPoly


var using_fake_id_flag: bool = false

@export var angle_x_max: float = 15.0
@export var angle_y_max: float = 15.0
@export var max_offset_shadow: float = 50.0

@export_category("Oscillator")
@export var spring: float = 150.0
@export var damp: float = 10.0
@export var velocity_multiplier: float = 2.0

var displacement: float = 0.0 
var oscillator_velocity: float = 0.0

var tween_rot: Tween
var tween_hover: Tween
var tween_destroy: Tween
var tween_handle: Tween

var last_mouse_pos: Vector2
var mouse_velocity: Vector2
var following_mouse: bool = false
var last_pos: Vector2
var velocity: Vector2

@onready var shadow = $Shadow

func _ready() -> void:
	#turn_on_collision()
	picture_selection.visible = false
	name_selection.visible = false
	breed_selection.visible = false
	angle_x_max = deg_to_rad(angle_x_max)
	angle_y_max = deg_to_rad(angle_y_max)
	scale = Vector2(0.55,0.55)
	#collision_shape.set_deferred("disabled", true) #probably not going to need

func turn_on_collision():
	print("on")
	$IDDrag/IDDragCollision.set_deferred("disabled", false)
	#$IDDrag.set_deferred("disable_mode", true)

func turn_off_collision():
	print("off")
	$IDDrag/IDDragCollision.set_deferred("disabled", true)
	$IDDrag.input_pickable = false

func set_id_values(_name: String, _breed: String, _idpic: String, _fakeid: String):
	id_picture_name = _idpic
	id_breed = _breed
	fake_id_picture_name = _fakeid
	id_name = _name
	id_picture_set.texture = load(fake_id_picture_name)

func _process(delta: float) -> void:
	id_name_label.set_text(str(id_name))
	id_breed_label.set_text(str(id_breed))
	rotate_velocity(delta)
	follow_mouse(delta)
	handle_shadow(delta)

func follow_mouse(delta: float) -> void:
	if not following_mouse: return
	var mouse_pos: Vector2 = get_global_mouse_position()
	global_position = mouse_pos - (get_viewport_rect().size/2.0)
	
func rotate_velocity(delta: float) -> void:
	if not following_mouse: return
	var center_pos: Vector2 = global_position - (get_viewport_rect().size/2.0)
	print("Pos: ", center_pos)
	print("Pos: ", last_pos)
	# Compute the velocity
	velocity = (position - last_pos) / delta
	last_pos = position
	
	print("Velocity: ", velocity)
	oscillator_velocity += velocity.normalized().x * velocity_multiplier
	
	# Oscillator stuff
	var force = -spring * displacement - damp * oscillator_velocity
	oscillator_velocity += force * delta
	displacement += oscillator_velocity * delta
	
	rotation = displacement
	
func handle_shadow(delta: float) -> void:
	# Y position is enver changed.
	# Only x changes depending on how far we are from the center of the screen
	var center: Vector2 = get_viewport_rect().size / 2.0
	var distance: float = global_position.x - center.x
	
	shadow.position.x = lerp(0.0, -sign(distance) * max_offset_shadow, abs(distance/(center.x)))


##################################################
## Signal Prcoessing
##################################################

func _on_picture_area_mouse_entered() -> void:
	mouse_entered_picture.emit()

func _on_picture_area_mouse_exited() -> void:
	mouse_exited_picture.emit()

func _on_name_area_mouse_entered() -> void:
	mouse_entered_name.emit()

func _on_name_area_mouse_exited() -> void:
	mouse_exited_name.emit()

func _on_breed_area_mouse_entered() -> void:
	mouse_entered_breed.emit()

func _on_breed_area_mouse_exited() -> void:
	mouse_exited_breed.emit()

func _on_id_drag_mouse_entered() -> void:
	mouse_enter_dragging.emit()

func _on_id_drag_mouse_exited() -> void:
	mouse_exit_dragging.emit()

func _on_id_drag_body_entered(body: Node2D) -> void:
	pass

func _on_id_drag_body_exited(body: Node2D) -> void:
	pass


func _on_id_drag_area_entered(area: Area2D) -> void:
	id_enter_body.emit()
	print("emit")


func _on_id_drag_area_exited(area: Area2D) -> void:
	id_exit_body.emit()
