extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var p1 := Vector2.ZERO
export var p2 := Vector2(450,350)
export var offset = 0
onready var base_offset = $"line-dashed".offset.y
export var mode := "request"
var margin = 40

onready var line = $"line-solid"
onready var head = $"head-out"

var is_red = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	match(mode):
		"allowed":
			line = $"line-dashed"
			$"line-dashed".visible = true
			$"head-out".modulate = Color(1,1,1)
			$"line-solid".visible = false
			$"head-in".visible = false
			$"head-out".visible = true
			$"head-out".modulate = Color(1,1,1)
		"allocation":
			line = $"line-solid"
			$"line-dashed".visible = false
			$"line-solid".visible = true
			$"line-solid".modulate = Color(0,1,0)
			$"head-in".visible = true
			$"head-in".modulate = Color(0,1,0)
			$"head-out".visible = false
		"request":
			line = $"line-solid"
			$"line-dashed".visible = false
			$"line-solid".visible = true
			$"line-solid".modulate = Color(1,1,0)
			$"head-in".visible = false
			$"head-out".visible = true
			$"head-out".modulate = Color(1,1,0)
		"new":
			line = $"line-solid"
			$"line-dashed".visible = false
			$"line-solid".visible = true
			$"line-solid".modulate = Color(1,1,1)
			$"head-in".visible = false
			$"head-out".visible = true
			$"head-out".modulate = Color(1,1,1)

	if is_red:
		$"line-solid".modulate = Color(1,0,0)
		$"line-dashed".modulate = Color(1,0,0)
		$"head-out".modulate = Color(1,0,0)
		$"head-in".modulate = Color(1,0,0)
	
	# offset for multi-line allocs
	line.offset.y = offset/line.scale.y+base_offset
	head.offset.y = offset/head.scale.y
	
	# Apply offset to get line draw points
	var local_p1 = p1 + Vector2.RIGHT.rotated(p2.angle_to_point(p1))*margin
	var local_p2 = p2 - Vector2.RIGHT.rotated(p2.angle_to_point(p1))*margin
	
	#drawing new line
	if mode=="new":
		p2=get_global_mouse_position()
		local_p2 = get_global_mouse_position()
	
	# bail if the points are too close
	if abs(local_p1.angle_to_point(local_p2) - p1.angle_to_point(p2)) > 1:
		$"line-dashed".visible = false
		$"line-solid".visible = false
		$"head-in".visible = false
		$"head-out".visible = false
		return
	
	# update the arrow sprites
	line.position = local_p1
	line.rotation = p2.angle_to_point(p1)
	line.region_rect.size.x = local_p1.distance_to(local_p2)
	
	head.position = local_p2
	head.rotation = p2.angle_to_point(p1)
	
	$"head-in".position = local_p1
	$"head-in".rotation = p2.angle_to_point(p1)
	
