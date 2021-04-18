extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var Node_res = preload("res://Scenes/GraphNode.tscn")
export var type := "process"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_self_gui_input(event):
	if Input.is_action_just_pressed("click") and $"/root/Graph".mode=="build_normal":
		var node = Node_res.instance()
		node.type = type
		node.position = get_global_mouse_position()
		node.selected = true
		node._on_Area2D_mouse_entered()
		$"/root/Graph/Nodes".add_child(node)
