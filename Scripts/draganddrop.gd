extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var selected = false
var offset := Vector2.ZERO
export var type := "process"

# Called when the node enters the scene tree for the first time.
func _ready():
	match type:
		"process":
			$ProcessIcon.visible = true
			$ResourceIcon.visible = false
		"resource":
			$ProcessIcon.visible = false
			$ResourceIcon.visible = true

func _input(event):
	if event.is_action_released("click"):
		selected=false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if selected:
		# global_position = lerp(global_position, get_global_mouse_position(), 25*delta)
		global_position = get_global_mouse_position() + offset


func _on_Area2D_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("click"):
		selected = true
		offset = global_position-get_global_mouse_position()
