extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var selected = false
var offset := Vector2.ZERO
export var type := "process"

onready var Graph = $"/root/Graph"

var hover

# Called when the node enters the scene tree for the first time.
func _ready():
	match type:
		"process":
			$ProcessIcon.visible = true
			$ResourceIcon.visible = false
		"resource":
			$ProcessIcon.visible = false
			$ResourceIcon.visible = true
	self.connect("new_arrow", Graph, "on_new_arrow")
	self.connect("end_arrow", Graph, "on_end_arrow")

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
		if Graph.mode == "build_normal":
			selected = true
			offset = global_position-get_global_mouse_position()


func _on_Area2D_mouse_entered():
	hover=true
	self.modulate = Color(0,1,1)


func _on_Area2D_mouse_exited():
	hover=false
	self.modulate = Color(1,1,1)
