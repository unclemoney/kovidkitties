class_name CatCharacter extends Node2D 

#Scene Loader
@onready var id_scene: PackedScene = preload("res://scenes/id_card.tscn")
@onready var cat_mask_scene:  PackedScene = preload("res://scenes/cat_mask.tscn")

@onready var cat_picture_set: Sprite2D = $CatSprite
@onready var mask_spawn: Node2D = $CatSprite/MaskSpawnPoint
@onready var id_spawn_point: Node2D = $IDSpawnPoint

#Character Objects
var id_card: IDCard
var cat_mask_object: CatMask

var is_cat_character_good: bool
var randomized_fake_index:int 
enum FAKE_CAT_ATTIBUTES {NO_MASK, FAKE_PICTURE, FAKE_FIRST_NAME, FAKE_LAST_NAME, BREED_MISMATCH} 

#Temp storage of Values for building cats
var cat_id_images = ["res://images/IDPicture_1.png", "res://images/IDPicture_2.png", "res://images/IDPicture_3.png", "res://images/IDPicture_4.png", "res://images/IDPicture_5.png", "res://images/IDPicture_6.png", "res://images/IDPicture_7.png"]
var cat_first_name = ["Sookie ", "Gypsy ", "Majiang ", "Guoqing "]
var cat_last_name = ["Pweety", "Baby", "Bunny"]
var cat_breed = ["BSH", "American", "Fold", "Rag Doll", "Hafu"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	build_character()

func randomize_character_good_bad():
	var random_dir = pow(-1, randi() % 2)
	var mask_status: bool
	if random_dir == -1:
		is_cat_character_good = false
	elif random_dir == 1:
		is_cat_character_good = true
	#print(is_cat_character_good)

func select_faked_attribute():
	if !is_cat_character_good:
		randomized_fake_index  = FAKE_CAT_ATTIBUTES.values()[ randi()%FAKE_CAT_ATTIBUTES.size() ]
		match randomized_fake_index:
			FAKE_CAT_ATTIBUTES.NO_MASK:
				wearking_mask(false)
				var id_sprite = cat_id_images.pick_random()
				id_card.set_id_values(cat_first_name.pick_random() + cat_last_name.pick_random() , cat_breed.pick_random(), id_sprite, id_sprite)
				print(FAKE_CAT_ATTIBUTES.keys()[randomized_fake_index])
			FAKE_CAT_ATTIBUTES.FAKE_PICTURE:
				wearking_mask(true)
				id_card.set_id_values(cat_first_name.pick_random() + cat_last_name.pick_random() , cat_breed.pick_random(), cat_id_images.pick_random(), cat_id_images.pick_random())
				print(FAKE_CAT_ATTIBUTES.keys()[randomized_fake_index])
			FAKE_CAT_ATTIBUTES.FAKE_FIRST_NAME:
				wearking_mask(true)
				var id_sprite = cat_id_images.pick_random()
				id_card.set_id_values("FAKES " + cat_last_name.pick_random() , cat_breed.pick_random(), id_sprite, id_sprite)
				print(FAKE_CAT_ATTIBUTES.keys()[randomized_fake_index])
			FAKE_CAT_ATTIBUTES.FAKE_LAST_NAME:
				wearking_mask(true)
				var id_sprite = cat_id_images.pick_random()
				id_card.set_id_values(cat_first_name.pick_random() + " MCFAKES" , cat_breed.pick_random(), id_sprite, id_sprite)
				print(FAKE_CAT_ATTIBUTES.keys()[randomized_fake_index])
			FAKE_CAT_ATTIBUTES.BREED_MISMATCH:
				wearking_mask(true)
				var id_sprite = cat_id_images.pick_random()
				id_card.set_id_values(cat_first_name.pick_random() + cat_last_name.pick_random() , "DOG", id_sprite, id_sprite)
				print(FAKE_CAT_ATTIBUTES.keys()[randomized_fake_index])
	elif is_cat_character_good:
		wearking_mask(true)
		var id_sprite = cat_id_images.pick_random()
		id_card.set_id_values(cat_first_name.pick_random() + cat_last_name.pick_random() , cat_breed.pick_random(), id_sprite, id_sprite)

func create_id():
	id_card = id_scene.instantiate()
	id_spawn_point.add_child(id_card)
	#id_card.set_id_values(cat_first_name.pick_random() + cat_last_name.pick_random() , cat_breed.pick_random(), cat_id_images.pick_random(), cat_id_images.pick_random())

func build_character():
	create_id()
	randomize_character_good_bad()
	select_faked_attribute()

func wearking_mask(_wearing_mask: bool):
	cat_mask_object = cat_mask_scene.instantiate()
	var random_dir = pow(-1, randi() % 2)
	var mask_status: bool = _wearing_mask
	mask_spawn.add_child(cat_mask_object)
	cat_mask_object.set_mask_status(mask_status)

func _process(delta: float) -> void:
	if is_instance_valid(id_card):
		cat_picture_set.texture = load(id_card.id_picture_name)
		#id_card.id_picture.texture = load(id_card.fake_id_picture_name)

func _on_tree_exiting() -> void:
	remove_child(id_card)
