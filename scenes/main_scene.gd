extends Node2D

#preload scenes
@onready var cat_scene: PackedScene = preload("res://scenes/cat_character.tscn") 
@onready var game_clock_scene: PackedScene = preload("res://scenes/game_clock.tscn") 
@onready var cell_phone_scene: PackedScene = preload("res://scenes/cell_phone.tscn")
@onready var cat_character: CatCharacter

#load spawn points
@onready var cat_spawn_point = $CanvasLayer/CatSpawnPoint
@onready var clock_spawn_point = $CanvasLayer/ClockSpawnPoint
@onready var cell_spawn_point = $CanvasLayer/CellPhoneSpawnPoint

@onready var correct_score_label = $CorrectScoreLabel
@onready var error_score_label = $ErrorScoreLabel
@onready var game_clock: GameClock
@onready var cell_phone: CellPhone

@onready var debug = $Debug

@export var angle_x_max: float = 15.0
@export var angle_y_max: float = 15.0
@export var max_offset_shadow: float = 50.0


#global vars
var mask_touched: bool = false
var mask_selected: bool = false
var picture_touched: bool = false
var picture_selected: bool = false
var name_touched: bool = false
var name_selected: bool = false
var breed_touched: bool = false
var breed_selected: bool = false
var id_dragging_area: bool = false
var id_dropable: bool = false
var id_placed: bool = false

var id_position_offset: Vector2 

var mouse_left_down: bool = false

var correct_score: int = 0
var error_score: int = 0 

#scaling vectors for ID card
var id_small_scale: Vector2 = Vector2(0.25, 0.25)
var id_pop_scale: Vector2 = Vector2(0.35, 0.35)
var id_placed_scale: Vector2 = Vector2(0.65, 0.65)

func _ready() -> void:
	var layout = Dialogic.start("res://timeline/timeline.dtl")
	layout.register_character("res://character/player.dch", $CanvasLayer/CellPhoneSpawnPoint)
	game_clock = game_clock_scene.instantiate()
	clock_spawn_point.add_child(game_clock)
	game_clock.on_duty = false
	cell_phone = cell_phone_scene.instantiate()
	cell_spawn_point.add_child(cell_phone)
	cell_phone.make_invisible()
	

func _process(delta: float) -> void:
	update_scores()
	if game_clock.on_duty:
		$NextDayButton.visible = false
	elif !game_clock.on_duty:
		$NextDayButton.visible = true
	if is_instance_valid(cat_character) && game_clock.on_duty:
		if id_dragging_area and !picture_touched and !breed_touched and !name_touched:
			if Input.is_action_just_pressed("mouse_click"):
				id_position_offset = get_global_mouse_position() - cat_character.id_card.global_position
				Global.id_dragging = true
				
			if Input.is_action_pressed("mouse_click") and Global.id_dragging:
				cat_character.id_card.global_position = get_global_mouse_position() - id_position_offset
				
			elif Input.is_action_just_released("mouse_click") and Global.id_dragging and id_dropable:
				Global.id_dragging = false
				id_placed = true
				var tween = get_tree().create_tween()
				tween.tween_property(cat_character.id_card,"position",Vector2(0,140), 0.2).set_ease(Tween.EASE_OUT)
				cat_character.id_card.scale = id_placed_scale

func update_scores():
	error_score_label.text = str(error_score)
	correct_score_label.text = str(correct_score)

func _input(event: InputEvent) -> void:
	if is_instance_valid(cat_character):
		if event.is_action_pressed("mouse_click") && !cat_character.is_cat_character_good:
			match cat_character.randomized_fake_index:
				cat_character.FAKE_CAT_ATTIBUTES.NO_MASK:
					if mask_touched:
						mask_selected = true
						cat_character.cat_mask_object.no_mask_selection.visible = true
				cat_character.FAKE_CAT_ATTIBUTES.FAKE_PICTURE:
					if picture_touched:
						picture_selected = true
						cat_character.id_card.picture_selection.visible = true
				cat_character.FAKE_CAT_ATTIBUTES.FAKE_FIRST_NAME:
					if name_touched:
						name_selected = true
						cat_character.id_card.name_selection.visible = true
				cat_character.FAKE_CAT_ATTIBUTES.FAKE_LAST_NAME:
					if name_touched:
						name_selected = true
						cat_character.id_card.name_selection.visible = true
				cat_character.FAKE_CAT_ATTIBUTES.BREED_MISMATCH:
					if breed_touched:
						breed_selected = true
						cat_character.id_card.breed_selection.visible = true
		elif event.is_action_pressed("mouse_click") && cat_character.is_cat_character_good:
			pass
			
	#old code, may note need
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			mouse_left_down = true
		elif event.button_index == 1 and not event.is_pressed():
			mouse_left_down = false

func _on_button_pressed() -> void:
	if !is_instance_valid(cat_character) && game_clock.on_duty && !cell_phone.visible:
		cat_character = cat_scene.instantiate()
		cat_spawn_point.add_child(cat_character)
		connect_mouse_signals()
		cat_character.id_card.scale = id_small_scale
	else:
		pass

func connect_mouse_signals() -> void:
	cat_character.cat_mask_object.mouse_entered.connect(_handle_mask_touched)
	cat_character.cat_mask_object.mouse_exited.connect(_handle_mask_untouched)
	cat_character.id_card.mouse_entered_name.connect(_handle_id_name_touch)
	cat_character.id_card.mouse_exited_name.connect(_handle_id_name_untouch)
	cat_character.id_card.mouse_entered_picture.connect(_handle_id_picture_touch)
	cat_character.id_card.mouse_exited_picture.connect(_handle_id_picture_untouch)
	cat_character.id_card.mouse_entered_breed.connect(_handle_id_breed_touch)
	cat_character.id_card.mouse_exited_breed.connect(_handle_id_breed_untouch)
	cat_character.id_card.mouse_enter_dragging.connect(_handle_id_dragging_enter)
	cat_character.id_card.mouse_exit_dragging.connect(_handle_id_dragging_exit)
	cat_character.id_card.id_enter_body.connect(_handle_id_body_enter)
	cat_character.id_card.id_exit_body.connect(_handle_id_body_exit)

func _on_accept_button_pressed() -> void:
	if is_instance_valid(cat_character):
		if !cat_character.is_cat_character_good:		
			print("bad job, they were not wearing a mask/had false documents, you have endangered all the other kitties")
			error_score += 1
			cell_phone.make_visible()
		if cat_character.is_cat_character_good:
			print("good job, this kitty is a good citizen for wearking a mask")
			correct_score += 1
		cat_character.queue_free()
		deselect_all()
	else:
		pass

func _on_reject_button_pressed() -> void:
	if is_instance_valid(cat_character):
		if cat_character.is_cat_character_good:
			error_score += 1
			cell_phone.make_visible()
			print("bad job, you have not allowed a good kitty in")
		elif !cat_character.is_cat_character_good && (breed_selected || mask_selected || picture_selected || name_selected):
			correct_score += 1
			print("good job, they were not wearing a mask/using fake id and should be punished")
		elif  (!breed_selected || !mask_selected || !picture_selected || !name_selected):
			error_score += 1
			cell_phone.make_visible()
			print("you have failed to criticize the cat for not wearing a mask/using a fake id")
		
		cat_character.queue_free()
		deselect_all()
	else:
		pass

func deselect_all():
	mask_selected = false
	picture_selected = false
	name_selected = false
	breed_selected = false
	Global.id_dragging = false
	id_placed = false

func _handle_mask_touched():
	mask_touched = true
	print("mask: " + str(mask_touched))
	
func _handle_mask_untouched():
	mask_touched = false
	print("mask: " + str(mask_touched))

func _handle_id_name_touch():
	name_touched = true
	print("name: " + str(name_touched))

func _handle_id_name_untouch():
	name_touched = false
	print("name: " + str(name_touched))

func _handle_id_picture_touch():
	picture_touched = true
	print("pic: " + str(picture_touched))

func _handle_id_picture_untouch():
	picture_touched = false
	
func _handle_id_breed_touch():
	breed_touched = true
	print("breed: " + str(breed_touched))

func _handle_id_breed_untouch() 	:
	breed_touched = false

func _handle_id_dragging_enter():
	if !Global.id_dragging && !id_placed:
		if cat_character.id_card.tween_hover and cat_character.id_card.tween_hover.is_running():
				cat_character.id_card.tween_hover.kill()
		cat_character.id_card.tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		cat_character.id_card.tween_hover.tween_property(cat_character.id_card, "scale", id_pop_scale, 0.5)
		id_dragging_area = true

func _handle_id_dragging_exit():
	if !Global.id_dragging && !id_placed:
		id_dragging_area = false
		if cat_character.id_card.tween_rot and cat_character.id_card.tween_rot.is_running():
			cat_character.id_card.tween_rot.kill()
		cat_character.id_card.tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	
	# Reset scale
		if cat_character.id_card.tween_hover and cat_character.id_card.tween_hover.is_running():
			cat_character.id_card.tween_hover.kill()
		cat_character.id_card.tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		cat_character.id_card.tween_hover.tween_property(cat_character.id_card, "scale", id_small_scale, 0.55)

func _handle_id_body_enter():
	id_dropable = true

func _handle_id_body_exit():
	id_dropable = false

func _on_next_day_button_pressed() -> void:
	if !game_clock.get_duty_status():
		game_clock.day += 1
		game_clock.start_day = true
