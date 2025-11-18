class_name GameClock extends Node2D

@export var start_hour: int = 9
@export var start_minute: int = 0
@export var finish_hour: int = 5
@export var finish_minute: int = 0
@export var timer: float = 0.0
@export var time_multiplier: float = 5.0
@export var am_pm: bool = false
@export var on_duty: bool = true
@export var date_day: int = 1
var start_day: bool = true
var hour: int = 9
var minute: int = 0
var day: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_time(delta)

func set_todays_time(_start_hour: int, _start_minute: int, _am_pm: bool, _finish_hour: int, _finish_minute: int):
	start_hour = _start_hour
	start_minute = _start_minute
	am_pm = _am_pm
	finish_hour = _finish_hour
	finish_minute = _finish_minute

func set_todays_day(_day):
	day = _day

func get_duty_status() -> bool:
	return on_duty

#SET DAYS, TURN GAME CLOCK ON AND OFF, WHEN DAY IS OVER TURN ON NEXT DAY

func update_time(delta):
	
	if start_day:
		date_day = day
		hour = start_hour
		minute = start_minute
		on_duty = true
		start_day = false
		
	$Date.text = str("DAY: %02d" %date_day)
	if on_duty:
		if am_pm:
			$Clock.text = str("%02d : " %hour + "%02d" %minute + " PM")
		else:
			$Clock.text = str("%02d : " %hour + "%02d" %minute + " AM")
		timer += delta * time_multiplier
		if timer >= 0.0:
			timer -= 1.0
			minute += 1
			if minute == 60:
				minute = 0
				minute += 1
				hour += 1
				if hour == 12:
					am_pm = true
				if hour == 13:
					minute = 0
					hour = 0
					hour += 1
				if hour == finish_hour:
					on_duty = false
